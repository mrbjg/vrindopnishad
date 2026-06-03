import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import 'animated_effects.dart';
import 'package:iconsax/iconsax.dart';

class DivineRulerPicker extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final double? itemWidth;
  final ValueChanged<double> onChanged;
  final Color? activeColor;
  final Color? textColor;

  const DivineRulerPicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1.0,
    this.itemWidth,
    required this.onChanged,
    this.activeColor,
    this.textColor,
  });

  @override
  State<DivineRulerPicker> createState() => _DivineRulerPickerState();
}

class _DivineRulerPickerState extends State<DivineRulerPicker> {
  late ScrollController _scrollController;
  late double _itemWidth;
  bool _isListening = false; // Initialize to false to ignore layout-induced scroll updates
  bool _isSnapping = false;
  double? _lastEmittedValue;
  bool _userIsInteracting = false; // Track whether the user is actively dragging/scrolling the ruler

  @override
  void initState() {
    super.initState();
    final subdivisions = ((widget.max - widget.min) / widget.step).toInt();
    _itemWidth = widget.itemWidth ?? (subdivisions > 50 ? 12.0 : 28.0);
    final initialOffset = ((widget.value - widget.min) / widget.step) * _itemWidth;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
    _lastEmittedValue = widget.value;

    // Enable scroll listening only after the first frame layout is completed and stable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isListening = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DivineRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value == _lastEmittedValue) {
        return;
      }
      final targetOffset = ((widget.value - widget.min) / widget.step) * _itemWidth;
      if (_scrollController.hasClients && (_scrollController.offset - targetOffset).abs() > 1.0) {
        _isListening = false;
        _scrollController.jumpTo(targetOffset);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _isListening = true;
          }
        });
      }
    }
  }

  void _onScroll() {
    if (!_isListening || !_userIsInteracting) return;
    final offset = _scrollController.offset;
    final newValue = widget.min + (offset / _itemWidth) * widget.step;
    final clampedValue = newValue.clamp(widget.min, widget.max);
    
    // Align to nearest step
    final stepsCount = ((clampedValue - widget.min) / widget.step).round();
    final steppedValue = widget.min + stepsCount * widget.step;
    
    if (steppedValue != widget.value) {
      _lastEmittedValue = steppedValue;
      HapticFeedback.selectionClick();
      widget.onChanged(steppedValue);
    }
  }

  void _snapToTick() {
    if (!_scrollController.hasClients || _isSnapping) return;
    final offset = _scrollController.offset;
    final stepsCount = (offset / _itemWidth).round();
    final targetOffset = stepsCount * _itemWidth;
    
    if ((offset - targetOffset).abs() > 0.5) {
      _isSnapping = true;
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      ).then((_) {
        _isSnapping = false;
      });
    }
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color textColor,
    required Color activeColor,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.9,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: textColor.withValues(alpha: 0.05),
          border: Border.all(
            color: textColor.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subdivisions = ((widget.max - widget.min) / widget.step).toInt();
    final activeColor = widget.activeColor ?? PremiumTokens.activeAccent;
    final textColor = widget.textColor ?? PremiumTokens.textPrimary;
    final initialOffset = ((widget.value - widget.min) / widget.step) * _itemWidth;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Accessibility Minus Button
        _buildStepButton(
          icon: Iconsax.minus,
          onTap: () {
            final newVal = (widget.value - widget.step).clamp(widget.min, widget.max);
            if (newVal != widget.value) {
              HapticFeedback.lightImpact();
              widget.onChanged(newVal);
            }
          },
          textColor: textColor,
          activeColor: activeColor,
        ),
        const SizedBox(width: 8),
        
        // 2. The scrollable ruler picker itself
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              final halfWidth = viewportWidth / 2;
              
              return SizedBox(
                height: 60,
                width: viewportWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Scrollable Ticks Ruler with horizontal ShaderMask fade out
                    ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.15, 0.85, 1.0],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification && notification.dragDetails != null) {
                            setState(() {
                              _userIsInteracting = true;
                            });
                          } else if (notification is ScrollEndNotification) {
                            setState(() {
                              _userIsInteracting = false;
                            });
                            _snapToTick();
                          }
                          return false;
                        },
                        child: AnimatedBuilder(
                          animation: _scrollController,
                          builder: (context, child) {
                            final scrollOffset = _scrollController.hasClients 
                                ? _scrollController.offset 
                                : initialOffset;
                            
                            return ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(
                                  left: halfWidth - (_itemWidth / 2),
                                  right: halfWidth - (_itemWidth / 2),
                              ),
                              itemCount: subdivisions + 1,
                              itemBuilder: (context, index) {
                                final value = widget.min + index * widget.step;
                                
                                // Display labels on major ticks.
                                final isMajor = subdivisions > 50 
                                    ? (value.toInt() % 10 == 0) 
                                    : (value.toInt() % 2 == 0);
                                    
                                final baseTickHeight = isMajor ? 18.0 : 10.0;
                                final baseTickColor = isMajor 
                                    ? textColor.withValues(alpha: 0.4) 
                                    : textColor.withValues(alpha: 0.15);
                                    
                                // Calculate distance to center for dynamic scaling/glowing effects
                                final distance = (index * _itemWidth - scrollOffset).abs();
                                final maxDistance = _itemWidth * 3.5;
                                final scaleFactor = (1.0 - (distance / maxDistance)).clamp(0.0, 1.0);
                                
                                // Custom premium styles
                                final tickHeight = baseTickHeight + (scaleFactor * 8.0);
                                final tickWidth = 1.2 + (scaleFactor * 0.8);
                                final tickColor = Color.lerp(baseTickColor, activeColor, scaleFactor)!;
                                
                                final labelScale = 1.0 + (scaleFactor * 0.22);
                                final labelColor = Color.lerp(textColor.withValues(alpha: 0.4), activeColor, scaleFactor)!;
                                
                                return SizedBox(
                                  width: _itemWidth,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Tick Mark Line
                                      Container(
                                        width: tickWidth,
                                        height: tickHeight,
                                        decoration: BoxDecoration(
                                          color: tickColor,
                                          borderRadius: BorderRadius.circular(1),
                                          boxShadow: scaleFactor > 0.5 
                                            ? [
                                                BoxShadow(
                                                  color: activeColor.withValues(alpha: scaleFactor * 0.25),
                                                  blurRadius: 3,
                                                  spreadRadius: 0.5,
                                                )
                                              ]
                                            : null,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Value Label
                                      if (isMajor)
                                        Transform.scale(
                                          scale: labelScale,
                                          child: Text(
                                            "${value.toInt()}",
                                            style: GoogleFonts.outfit(
                                              fontSize: 9,
                                              fontWeight: scaleFactor > 0.5 
                                                ? FontWeight.w900 
                                                : FontWeight.bold,
                                              color: labelColor,
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(height: 11),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // 2. High-Fidelity Center Dial needle Pin (Tuner Indicator)
                    Positioned(
                      top: 0,
                      bottom: 18,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top glowing LED bead
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: activeColor.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            // Glowing line
                            Expanded(
                              child: Container(
                                width: 2.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      activeColor,
                                      activeColor.withValues(alpha: 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            // Bottom tiny dot above label area
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: activeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        
        // 3. Accessibility Plus Button
        _buildStepButton(
          icon: Iconsax.add,
          onTap: () {
            final newVal = (widget.value + widget.step).clamp(widget.min, widget.max);
            if (newVal != widget.value) {
              HapticFeedback.lightImpact();
              widget.onChanged(newVal);
            }
          },
          textColor: textColor,
          activeColor: activeColor,
        ),
      ],
    );
  }
}
