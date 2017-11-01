/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_libmailcore_AbstractPart */

#ifndef _Included_com_libmailcore_AbstractPart
#define _Included_com_libmailcore_AbstractPart
#ifdef __cplusplus
extern "C" {
#endif
#undef com_libmailcore_AbstractPart_serialVersionUID
#define com_libmailcore_AbstractPart_serialVersionUID 1LL
/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    partType
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_libmailcore_AbstractPart_partType
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setPartType
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setPartType
  (JNIEnv *, jobject, jint);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    filename
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_filename
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setFilename
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setFilename
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    mimeType
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_mimeType
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setMimeType
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setMimeType
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    charset
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_charset
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setCharset
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setCharset
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    uniqueID
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_uniqueID
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setUniqueID
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setUniqueID
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    contentID
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_contentID
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setContentID
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setContentID
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    contentLocation
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_contentLocation
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setContentLocation
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setContentLocation
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    contentDescription
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_contentDescription
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setContentDescription
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setContentDescription
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    isInlineAttachment
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_libmailcore_AbstractPart_isInlineAttachment
  (JNIEnv *, jobject);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setInlineAttachment
 * Signature: (Z)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setInlineAttachment
  (JNIEnv *, jobject, jboolean);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    partForContentID
 * Signature: (Ljava/lang/String;)Lcom/libmailcore/AbstractPart;
 */
JNIEXPORT jobject JNICALL Java_com_libmailcore_AbstractPart_partForContentID
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    partForUniqueID
 * Signature: (Ljava/lang/String;)Lcom/libmailcore/AbstractPart;
 */
JNIEXPORT jobject JNICALL Java_com_libmailcore_AbstractPart_partForUniqueID
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    setContentTypeParameter
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_libmailcore_AbstractPart_setContentTypeParameter
  (JNIEnv *, jobject, jstring, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    contentTypeParameterValueForName
 * Signature: (Ljava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_libmailcore_AbstractPart_contentTypeParameterValueForName
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_libmailcore_AbstractPart
 * Method:    allContentTypeParametersNames
 * Signature: ()Ljava/util/AbstractList;
 */
JNIEXPORT jobject JNICALL Java_com_libmailcore_AbstractPart_allContentTypeParametersNames
  (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif
#endif
