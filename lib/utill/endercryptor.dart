import 'dart:convert';
import 'package:pointycastle/api.dart';
import 'dart:typed_data';
import "package:pointycastle/export.dart";
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class EnDeCryptor{

  String rsaEncryptString(RSAPublicKey myPublic, String dataToEncrypt) {
    Uint8List dataBytes = Uint8List.fromList(utf8.encode(dataToEncrypt));

    final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

    Uint8List encryptedBytes = _processInBlocks(encryptor, dataBytes);

    return base64.encode(encryptedBytes);
  }

  String rsaDecryptString(RSAPrivateKey myPrivate, String cipherText) {
    Uint8List encryptedBytes = base64.decode(cipherText);

    final decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

    Uint8List decryptedBytes = _processInBlocks(decryptor, encryptedBytes);

    return utf8.decode(decryptedBytes);
}

  Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
    ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
    ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
    input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
    ? output
        : output.sublist(0, outputOffset);
    }


  Future<String> imageToBase64(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      List<int> imageBytes = response.bodyBytes;
      String base64String = base64Encode(imageBytes);
      return base64String;
    } else {
      throw Exception('Failed to load image from URL: $imageUrl');
    }
  }

  DecorationImage imageFromBase64(String base64String) {
    Uint8List decodedBytes = base64Decode(base64String);
    MemoryImage memoryImage = MemoryImage(decodedBytes);
    return DecorationImage(image: memoryImage, fit: BoxFit.cover);
  }
}