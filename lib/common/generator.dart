import 'dart:math';

import 'package:username_gen/username_gen.dart';

final roomNameGen = UsernameGen()
  ..setNames([
    'Linggarjati',
    'Renville',
    'Meja Bundar',
    'Roem Royen',
    'Inter',
    'Giyanti',
    'Bongaya',
    'Jepara',
    'Salatiga',
  ])
  ..setSeperator(' ')
  ..setAdjectives([
    'Ruang',
    'Kelas',
    'Kelompok',
    'Konferensi',
  ]);

extension RandomUsernameGen on UsernameGen {
  String generate() {
    final ranA = (Random().nextDouble() * data.names.length).floor();
    final ranB = (Random().nextDouble() * data.adjectives.length).floor();
    final ranSuffix = (Random().nextDouble() * 100).floor();
    return "${data.adjectives[ranB]}$seperator${data.names[ranA]}$ranSuffix";
  }
}
