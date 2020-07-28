import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cacheNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context,url)=>Padding(
      padding: EdgeInsets.all(20.0),
      child: CircularProgressIndicator(
        backgroundColor: Colors.white30,
      ),
    ),
    errorWidget: (context,url,error)=>Icon(Icons.error),
  );
}
