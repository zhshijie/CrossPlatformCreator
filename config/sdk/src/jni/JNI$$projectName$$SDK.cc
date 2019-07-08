#include "JNI$$projectName$$SDK.h"
#include "../Header/$$projectName$$.h"

static JavaVM *g_JavaVM = nullptr;

JNINativeMethod g_Methods[] = {
    { "hello", "()V", (void*)Java_$$packageId$$_$$projectName$$Sdk_hello}
    
};

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved)
{
    g_JavaVM = vm;
    JNIEnv *pEnv = NULL;
    if (vm->GetEnv((void**)&pEnv, JNI_VERSION_1_6) != JNI_OK) {
        return -1;
    }
    jclass nativeClass = pEnv->FindClass(ClassName("$$projectName$$").c_str());
    CHECK_EXCEPTION(pEnv);
    if (nullptr == nativeClass) {
        return -2;
    }
    jint ret = pEnv->RegisterNatives(nativeClass, g_Methods, sizeof(g_Methods) / sizeof(g_Methods[0]));
    CHECK_EXCEPTION(pEnv);
    if (ret != JNI_OK) {
        return -3;
    }    

    return JNI_VERSION_1_6;
}

JNIEXPORT void JNICALL Java_$$packageId$$_$$projectName$$Sdk_hello(JNIEnv *, jclass)
{
    hello();
}
