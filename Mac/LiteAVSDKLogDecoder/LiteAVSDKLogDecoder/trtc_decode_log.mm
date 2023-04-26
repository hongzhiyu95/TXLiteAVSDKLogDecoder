#include "trtc_decode_log.h"
#import <zlib.h>

constexpr int kMagicNoCompressStart = 0x03;
constexpr int kMagicCompressStart = 0x04;
constexpr int kMagicCompressStart1 = 0x05;
constexpr int kMagicEnd = 0x00;

TRTCDecodeLog::TRTCDecodeLog()
    :m_inBuffer(nullptr)
    , m_inBufferSize(0)
    , m_fileDir("")
    , m_fileExt("")
    , m_fileName("")
    , m_lastSeq(0) {

}

TRTCDecodeLog::~TRTCDecodeLog() {
    if (nullptr != m_inBuffer)
    {
        delete[] m_inBuffer;
        m_inBuffer = nullptr;
    }

    if (m_outFile.is_open())
    {
        m_outFile.close();
    }

    if (m_inFile.is_open())
    {
        m_inFile.close();
    }
}
void TRTCDecodeLog::setDecodeCallBack(TRTCDecodeCallback *callback){
    _callBack = callback;
}
void TRTCDecodeLog::parseFile(const std::string& path) {
    m_inFile.open(path.c_str(), std::ios::in | std::ios::binary);
    if (!m_inFile.is_open())
    {
        printf("TRTCDecodeLog::setPath %s file opening failed!\n", path.c_str());
        return;
    }

    std::string::size_type iPos = (path.find_last_of('\\') + 1) == 0 ? path.find_last_of('/') + 1 : path.find_last_of('\\') + 1;
    std::string fileName = path.substr(iPos, path.length() - iPos);
    m_fileDir = path.substr(0, iPos);
    m_fileName = fileName.substr(0, fileName.rfind('.'));
    m_fileExt = fileName.substr(fileName.rfind('.') + 1, fileName.length());

    std::string outFilePath = path + ".log";
   // m_outFile.write(outfile, 0);
    m_outFile.open(outFilePath, std::ios::app);
    if (!m_outFile.is_open())
    {
        printf("TRTCDecodeLog::setPath %s file creation failed!\n", outFilePath.c_str());
    }
    if (decode())
    {
        printf("url:%s decode log success\n", outFilePath.c_str());
        if (_callBack != NULL) {
            _callBack->decodeComplete(this);

        }
        
    }
    else
    {
        printf("url:%s decode log fail\n", outFilePath.c_str());
    }
}

bool TRTCDecodeLog::decode() {
    if (!m_outFile.is_open() || !m_inFile.is_open())
    {
        printf("TRTCDecodeLog::decode Failed to create or open the file, unable to decode the log!");
        return false;
    }
    m_inFile.seekg(0, m_inFile.end);
    m_inBufferSize = m_inFile.tellg();
    m_inBuffer = new char[m_inBufferSize] {0};
    m_inFile.seekg(0, m_inFile.beg);
    m_inFile.read(m_inBuffer, m_inBufferSize);
    if (m_fileExt == "clog")
    {
        return clog();
    }
    if (m_fileExt == "xlog")
    {
        return xlog();
    }
    return false;
}

bool TRTCDecodeLog::xlog() {
    std::streampos startPos = getLogStartPos(m_inBuffer, 2);
    if (startPos == -1)
    {
        printf("TRTCDecodeLog::xlog getLogStartPos return -1\n");
        return false;
    }

    while (true)
    {
        startPos = decodeBuffer(m_inBuffer, startPos);
        if (startPos == -1)
        {
            break;
        }
    }

    return true;
}

bool TRTCDecodeLog::clog() {
    char *decompBuffer = nullptr;
    size_t decompBufferSize = 0;
    if (!zlibDecompress(m_inBuffer, m_inBufferSize, &decompBuffer, &decompBufferSize)){
        printf("TRTCDecodeLog::decodeBuffer Decompress error\n");
        return false;
    }
    m_outFile.write(decompBuffer, decompBufferSize);
    return true;
}

bool TRTCDecodeLog::isGoodLogBuffer(const char* buffer, std::streamsize offset, int count) {
    if (offset == m_inBufferSize)
    {
        return true;
    }

    std::streamsize headerLength = 0;
    if (kMagicNoCompressStart == buffer[offset] || kMagicCompressStart == buffer[offset] || kMagicCompressStart1 == buffer[offset])
    {
        headerLength = 1 + 2 + 1 + 1 + 4 + 4;
    }
    else
    {
        printf("TRTCDecodeLog::isGoodLogBuffer buffer[%lld] != MAGIC_NUM_START\n", offset);
        return false;
    }

    if (offset + headerLength + 1 + 1 > m_inBufferSize)
    {
        printf("TRTCDecodeLog::isGoodLogBuffer offset(%lld) > buffer(%lld)\n", offset, m_inBufferSize);
        return false;
    }

    uint32_t length;
    memcpy(&length, &buffer[offset + headerLength - 4 - 4], 4);
    if (offset + headerLength + length + 1 > m_inBufferSize)
    {
        printf("TRTCDecodeLog::isGoodLogBuffer log length:%d, end pos %lld > buffer(%lld)\n", length, offset + headerLength + length + 1, m_inBufferSize);
        return false;
    }

    if (kMagicEnd != buffer[offset + headerLength + length])
    {
        printf("TRTCDecodeLog::isGoodLogBuffer log length:%d, buffer[%lld] != MAGIC_END\n", length, offset + headerLength + length);
        return false;
    }

    if (1 >= count)
    {
        return true;
    }
    else
    {
        return isGoodLogBuffer(buffer, offset + headerLength + length + 1, count - 1);
    }
}

std::streampos TRTCDecodeLog::getLogStartPos(const char* buffer, int count) {
    std::streamsize offset = 0;
    while (true)
    {
        if (offset >= m_inBufferSize)
        {
            break;
        }

        if (kMagicNoCompressStart == buffer[offset] || kMagicCompressStart == buffer[offset] || kMagicCompressStart1 == buffer[offset])
        {
            if (isGoodLogBuffer(buffer, offset, count))
            {
                return offset;
            }
        }
        ++offset;
    }
    return -1;
}

bool TRTCDecodeLog::zlibDecompress(const char* compressedBytes, size_t compressedBytesSize, char** outBuffer, size_t* outBufferSize) {

    *outBuffer = NULL;
    *outBufferSize = 0;
    if (compressedBytesSize == 0)
    {
        return true;
    }

    unsigned fullLength = compressedBytesSize;
    unsigned halfLength = compressedBytesSize / 2;

    unsigned uncompLength = fullLength;
    char* uncomp = new char[uncompLength] {0};

    z_stream strm;
    strm.next_in = (Bytef*)compressedBytes;
    strm.avail_in = compressedBytesSize;
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;

    bool done = false;

    if (inflateInit2(&strm, (-MAX_WBITS)) != Z_OK)
    {
        delete[] uncomp;
        uncomp = nullptr;
        return false;
    }

    while (!done)
    {
        strm.next_out = (Bytef*)(uncomp + strm.total_out);
        strm.avail_out = uncompLength - strm.total_out;

        // Inflate another chunk.
        int err = inflate(&strm, Z_SYNC_FLUSH);
        // decompress success
        if (strm.total_in == compressedBytesSize) {
            break;
        }
        if (err == Z_STREAM_END || err == Z_BUF_ERROR
            || err == Z_DATA_ERROR)
        {
            done = true;
        }
        //        else if (err != Z_OK)
        //        {
        //            break;
        //        }

                // If our output buffer is too small
        if (strm.total_out >= uncompLength)
        {
            // Increase size of output buffer
            char* uncomp2 = new char[uncompLength + halfLength]{ 0 };
            memcpy(uncomp2, uncomp, uncompLength);
            uncompLength += halfLength;
            delete[] uncomp;
            uncomp = uncomp2;
        }
    }

    if (inflateEnd(&strm) != Z_OK)
    {
        delete[] uncomp;
        uncomp = nullptr;
        return false;
    }

    *outBuffer = uncomp;
    *outBufferSize = strm.total_out;
    return true;
}

std::streampos TRTCDecodeLog::decodeBuffer(const char* buffer, std::streamsize offset) {
    if (offset >= m_inBufferSize)
    {
        printf("TRTCDecodeLog::decodeBuffer offset[%lld] >= bufferSize[%lld]\n", offset, m_inBufferSize);
        return -1;
    }

    if (!isGoodLogBuffer(buffer, offset, 1))
    {
        std::streamsize fixPos = getLogStartPos(buffer + offset, 1);
        if (fixPos == -1)
        {
            printf("TRTCDecodeLog::decodeBuffer getLogStartPos return -1\n");
            return -1;
        }
        else
        {
            char text[128] = { 0 };
            snprintf(text, sizeof(text), "[F]TRTCDecodeLog::decodeBuffer decode error len=%lld\n", fixPos);
            m_outFile.write(text, sizeof(text));
            offset += fixPos;
        }
    }

    std::streamsize headerLength = 0;
    if (kMagicNoCompressStart == buffer[offset] || kMagicCompressStart == buffer[offset] || kMagicCompressStart1 == buffer[offset])
    {
        headerLength = 1 + 2 + 1 + 1 + 4 + 4;
    }
    else
    {
        char text[128] = { 0 };
        snprintf(text, sizeof(text), "in DecodeBuffer buffer[%lld]:%d != MAGIC_NUM_START\n", offset, (int)buffer[offset]);
        m_outFile.write(text, sizeof(text));
        return -1;
    }

    uint32_t length;
    memcpy(&length, &buffer[offset + headerLength - 4 - 4], 4);

    unsigned short seq;
    memcpy(&seq, &buffer[offset + headerLength - 4 - 4 - 2 - 2], 2);

    char beginHour;
    memcpy(&beginHour, &buffer[offset + headerLength - 4 - 4 - 1 - 1], 1);

    char endHour;
    memcpy(&endHour, &buffer[offset + headerLength - 4 - 4 - 1], 1);

    if (seq != 0 && seq != 1 && m_lastSeq != 0 && seq != (m_lastSeq + 1))
    {
        char text[128] = { 0 };
        snprintf(text, sizeof(text), "[F]decode_log_file.py log seq:%d-%d is missing\n", m_lastSeq + 1, seq - 1);
        m_outFile.write(text, sizeof(text));
    }

    if (seq != 0)
    {
        m_lastSeq = seq;
    }

    char* tmpBuffer = new char[length] {0};
    size_t tmpBufferSize = length;
    if (tmpBuffer == NULL)
    {
        printf("TRTCDecodeLog::decodeBuffer gMemory error\n");
        exit(2);
    }

    if (kMagicCompressStart == buffer[offset])
    {
        for (size_t i = 0; i < length; i++)
        {
            tmpBuffer[i] = buffer[offset + headerLength + i];
        }

        char* decompBuffer = nullptr;
        size_t decompBufferSize = 0;
        if (!zlibDecompress(tmpBuffer, tmpBufferSize, &decompBuffer, &decompBufferSize))
        {
            printf("TRTCDecodeLog::decodeBuffer Decompress error\n");
            exit(6);
        }
        delete[] tmpBuffer;
        tmpBuffer = decompBuffer;
        tmpBufferSize = decompBufferSize;
    }
    else if (kMagicCompressStart1 == buffer[offset])
    {
        size_t readPos = 0;
        size_t tmpBufferWritePos = 0;
        while (readPos < length)
        {
            uint16_t singleLogLen;
            memcpy(&singleLogLen, buffer + offset + headerLength + readPos, 2);
            appendBuffer(&tmpBuffer, &tmpBufferSize, &tmpBufferWritePos,
                buffer + offset + headerLength + readPos + 2, singleLogLen);
            readPos += singleLogLen + 2;
        }

        char* decompBuffer = nullptr;
        size_t decompBufferSize = 0;
        if (!zlibDecompress(tmpBuffer, tmpBufferSize, &decompBuffer, &decompBufferSize))
        {
            printf("TRTCDecodeLog::decodeBuffer Decompress error\n");
            exit(6);
        }
        delete[] tmpBuffer;
        tmpBuffer = decompBuffer;
        tmpBufferSize = decompBufferSize;
    }

    m_outFile.write(tmpBuffer, tmpBufferSize);
    return offset + headerLength + length + 1;
}


void TRTCDecodeLog::appendBuffer(char** outBuffer, size_t* outBufferSize, size_t* writePos, const char* buffer, size_t bufferSize) {
    if ((*outBufferSize) - (*writePos) < bufferSize + 1) // + 1 for last \0
    {
        char* newOutBuffer = (char*)realloc(*outBuffer, (*outBufferSize) + 2 * bufferSize);
        if (NULL != newOutBuffer)
        {
            *outBuffer = newOutBuffer;
            *outBufferSize = (*outBufferSize) + 2 * bufferSize;
        }
        else
        {
            free(*outBuffer);
            fputs("Error reallocating memory", stderr);
            exit(5);
        }
    }

    memcpy(*outBuffer + (*writePos), buffer, bufferSize);
    *writePos = (*writePos) + bufferSize;
}
