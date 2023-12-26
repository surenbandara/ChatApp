import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'dart:math';
import 'dart:typed_data';
import "package:pointycastle/export.dart";
import 'package:pem/pem.dart';
import 'dart:convert';
import 'package:pointycastle/pointycastle.dart';

class KeyIdGenerator{

  String generateUniqueId(String useremail , String selfemail) {
    int milliseconds = DateTime.now().millisecondsSinceEpoch;
    String input = '$milliseconds-$useremail-$selfemail';

    // Create an MD5 hash
    var bytes = utf8.encode(input);
    var md5Hash = md5.convert(bytes);

    // Convert the hash to a hexadecimal string
    String uniqueId = md5Hash.toString();

    return uniqueId;
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      {int bitLength = 2048}) {
    // Create an RSA key generator and initialize it
    SecureRandom secureRandom = exampleSecureRandom();

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom));

    // Use the generator

    final pair = keyGen.generateKeyPair();

    // Cast the generated key pair into the RSA key types

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  SecureRandom exampleSecureRandom() {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }

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

  Uint8List _processInBlocks(
      AsymmetricBlockCipher engine, Uint8List input) {
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

  // String publicKeyToPem(RSAPublicKey publicKey) {
  //   final rsaPublicKey = RSAPublicKey(
  //     publicKey.modulus!,
  //     publicKey.exponent!,
  //   );
  //
  //   final pemBlock = PemBlock(
  //     type: 'RSA PUBLIC KEY',
  //     bytes: rsaPublicKey.encodeToDER(),
  //   );
  //
  //   return PemCodec(PemLabel.publicKey).encode(pemBlock);
  // }


}