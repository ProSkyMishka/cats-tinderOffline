import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cat.dart';

class SwipeableCard extends StatefulWidget {
  final Cat cat;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const SwipeableCard({
    Key? key,
    required this.cat,
    required this.onLike,
    required this.onDislike,
  }) : super(key: key);

  @override
  _SwipeableCardState createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _controller.addListener(() {
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void animateOutAndFetch(double endX) {
    if (endX > 0) {
      widget.onLike();
    } else {
      widget.onDislike();
    }
    setState(() => _offset = Offset.zero);
  }

  void animateBack() {
    setState(() => _offset = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double opacity = (_offset.dx.abs() / (screenWidth * 0.4)).clamp(0.0, 1.0);
    bool isLike = _offset.dx > 0;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() => _offset += details.delta);
      },
      onPanEnd: (details) {
        if (_offset.dx.abs() > screenWidth * 0.4) {
          final endX = _offset.dx > 0 ? screenWidth : -screenWidth;
          animateOutAndFetch(endX);
        } else {
          animateBack();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            transform: Matrix4.translationValues(_offset.dx, 0, 0),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.cat.imageUrl,
                  placeholder: (context, url) => SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, size: 60),
                  ),
                  height: 300,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text(
                  widget.cat.breedName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: isLike ? 20 : null,
            right: isLike ? null : 20,
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: isLike ? -0.2 : 0.2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isLike
                        ? Colors.green.withOpacity(0.7)
                        : Colors.red.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLike ? Icons.thumb_up : Icons.thumb_down,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
