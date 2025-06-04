import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/pages/rank/zone/index.dart';

enum RandType {
  all,
  creation,
  animation,
  music,
  dance,
  game,
  knowledge,
  technology,
  sport,
  car,
  life,
  food,
  animal,
  madness,
  fashion,
  entertainment,
  film,
  documentary,
  movie,
  teleplay
}

extension RankTypeDesc on RandType {
  String get description => [
        'All',
        'Creation',
        'Animation',
        'Music',
        'Dance',
        'Gaming',
        'Video Essay',
        'Tech',
        'Sports',
        'Cars',
        'Life',
        'Food',
        'Animals',
        'Memes',
        'Fashion',
        'Entertainment',
        'Film',
        'Documentary',
        'Movie',
        'Teleplay'
      ][index];

  String get id => [
        'all',
        'creation',
        'animation',
        'music',
        'dance',
        'game',
        'knowledge',
        'technology',
        'sport',
        'car',
        'life',
        'food',
        'animal',
        'madness',
        'fashion',
        'entertainment',
        'film',
        'documentary',
        'movie',
        'teleplay'
      ][index];
}

List tabsConfig = [
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'All',
    'type': RandType.all,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '0'),
    'page': const ZonePage(rid: 0),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Creation',
    'type': RandType.creation,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '168'),
    'page': const ZonePage(rid: 168),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Animation',
    'type': RandType.animation,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '1'),
    'page': const ZonePage(rid: 1),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Music',
    'type': RandType.music,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '3'),
    'page': const ZonePage(rid: 3),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Dance',
    'type': RandType.dance,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '129'),
    'page': const ZonePage(rid: 129),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Gaming',
    'type': RandType.game,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '4'),
    'page': const ZonePage(rid: 4),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Video Essay',
    'type': RandType.knowledge,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '36'),
    'page': const ZonePage(rid: 36),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Tech',
    'type': RandType.technology,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '188'),
    'page': const ZonePage(rid: 188),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Sports',
    'type': RandType.sport,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '234'),
    'page': const ZonePage(rid: 234),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Cars',
    'type': RandType.car,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '223'),
    'page': const ZonePage(rid: 223),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Life',
    'type': RandType.life,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '160'),
    'page': const ZonePage(rid: 160),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Food',
    'type': RandType.food,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '211'),
    'page': const ZonePage(rid: 211),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Animals',
    'type': RandType.animal,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '217'),
    'page': const ZonePage(rid: 217),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Memes',
    'type': RandType.madness,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '119'),
    'page': const ZonePage(rid: 119),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Fashion',
    'type': RandType.fashion,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '155'),
    'page': const ZonePage(rid: 155),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Entertainment',
    'type': RandType.entertainment,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '5'),
    'page': const ZonePage(rid: 5),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Film',
    'type': RandType.film,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '181'),
    'page': const ZonePage(rid: 181),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Documentary',
    'type': RandType.documentary,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '177'),
    'page': const ZonePage(rid: 177),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Movie',
    'type': RandType.movie,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '23'),
    'page': const ZonePage(rid: 23),
  },
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': 'Teleplay',
    'type': RandType.teleplay,
    'ctr': Get.put<ZoneController>(ZoneController(), tag: '11'),
    'page': const ZonePage(rid: 11),
  }
];
