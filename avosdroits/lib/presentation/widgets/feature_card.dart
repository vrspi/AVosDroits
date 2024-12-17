import 'package:flutter/material.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/theme/design_system.dart';

class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        if (!isMobile) {
          setState(() => _isHovered = false);
          _controller.reverse();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            boxShadow: _isHovered ? DesignSystem.cardShadow : DesignSystem.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  gradient: _isHovered
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            DesignSystem.primaryGreen.withOpacity(0.05),
                            DesignSystem.secondaryGreen.withOpacity(0.1),
                          ],
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            DesignSystem.primaryGreen.withOpacity(0.1),
                            DesignSystem.secondaryGreen.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                      ),
                      child: Icon(
                        widget.icon,
                        size: isMobile ? 28 : 32,
                        color: DesignSystem.primaryGreen,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    Text(
                      widget.title,
                      style: (isMobile ? DesignSystem.headingMedium : DesignSystem.headingLarge)
                          .copyWith(
                            color: DesignSystem.darkText,
                            fontSize: isMobile ? 18 : (isDesktop ? 22 : 20),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: DesignSystem.bodyLarge.copyWith(
                        color: DesignSystem.lightText,
                        fontSize: isMobile ? 14 : 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 