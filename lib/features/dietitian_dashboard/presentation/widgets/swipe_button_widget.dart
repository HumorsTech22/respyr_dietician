import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_state.dart';

class SwipeButtonWidget extends StatefulWidget {
  const SwipeButtonWidget({super.key});

  @override
  State<SwipeButtonWidget> createState() => _SwipeButtonWidgetState();
}

class _SwipeButtonWidgetState extends State<SwipeButtonWidget> {
  double _dragPosition = 0.0;
  bool _swiped = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double height = 65.0;
    const double width = 206.0;
    const double padding = 7.0;

    const dragThreshold = 0.50;

    return BlocListener<DietitianDashboardCubit, DietitianDashboardState>(
      listener: (context, state) {
        if (state is DietitianDashboardSwipeSuccess) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_isDisposed && mounted) {
              setState(() {
                _dragPosition = 0.0;
                _swiped = false;
              });
            }
            if (context.mounted) {
              context.read<DietitianDashboardCubit>().resetSwipe();
            }
          });
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white54, Colors.grey.shade300],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Colors.grey.shade300,
                    Color(0xFFD0D0D0),
                    Colors.grey.shade300,
                  ],
                ),
              ),
            ),

            Positioned(
              left: padding + _dragPosition,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (!mounted) return;
                  setState(() {
                    _dragPosition += details.delta.dx;
                    _dragPosition = _dragPosition.clamp(
                      0.0,
                      width - height - (padding * 1.5),
                    );
                  });
                },
                onHorizontalDragEnd: (_) {
                  if (_dragPosition >
                      (width - height - (padding * 1.5)) * dragThreshold) {
                    if (!mounted) return;
                    setState(() => _swiped = true);
                    context.read<DietitianDashboardCubit>().onSwipeComplete(
                      context,
                    );
                  } else {
                    if (!mounted) return;
                    setState(() => _dragPosition = 0.0);
                  }
                },
                child: Container(
                  width: height - 8,
                  height: height - 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF308BF9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
