#ifndef __DECODELOG_H__
#define __DECODELOG_H__
#include <string>
#include <fstream>
class TRTCDecodeLog;
class TRTCDecodeCallback {
    
   
public:
    virtual void decodeComplete(TRTCDecodeLog *decoder,const std::string &filePath){};
    TRTCDecodeCallback(){};
    ~TRTCDecodeCallback(){};
};
class TRTCDecodeLog
{
public:
    TRTCDecodeLog();
    ~TRTCDecodeLog();
    void setDecodeCallBack(TRTCDecodeCallback* callback);
    void parseFile(const std::string& path,const std::string& outpath);
private:
    bool decode();

    bool xlog();

    bool clog();
    TRTCDecodeCallback* _callBack;
    std::streampos getLogStartPos(const char*buffer, int count);

    std::streampos decodeBuffer(const char*buffer,std::streamsize offset);

    bool isGoodLogBuffer(const char*buffer, std::streamsize offset, int count);

    bool zlibDecompress(const char* compressedBytes, size_t compressedBytesSize, char** outBuffer, size_t* outBufferSize);

    void appendBuffer(char** outBuffer, size_t* outBufferSize, size_t* writePos, const char* buffer, size_t bufferSize);
private:
    std::string m_fileDir;
    std::string m_fileName;
    std::string m_fileExt;
    std::ofstream m_outFile;
    std::ifstream m_inFile;
    std::streamsize m_inBufferSize;
    char * m_inBuffer;
    int m_lastSeq;

};

#endif // !__DECODELOG_H__
