import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MostRequestedMaterialsChart extends StatefulWidget {
  const MostRequestedMaterialsChart({super.key});

  @override
  State<MostRequestedMaterialsChart> createState() => _MostRequestedMaterialsChartState();
}

class _MostRequestedMaterialsChartState extends State<MostRequestedMaterialsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  final List<MaterialData> data = [
    MaterialData('Electronic\nComponents', 18, const Color(0xFF2D6A4F)),
    MaterialData('Plastic', 12, const Color(0xFFB27A3B)),
    MaterialData('Metal', 9, const Color(0xFF8B3A2E)),
    MaterialData('Glass', 7, const Color(0xFF6E4B7E)),
    MaterialData('Chemical', 5, const Color(0xFFA69B5D)),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Requested Materials (Last 30 Days)',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 300.h,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        tooltipRoundedRadius: 8.r,
                        tooltipPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${data[group.x].name.replaceAll('\n', ' ')}\n${rod.toY.round()} requests',
                            GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              barTouchResponse == null ||
                              barTouchResponse.spot == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                data[value.toInt()].name,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                          reservedSize: 40.h,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              value.toInt().toString(),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 12.sp,
                              ),
                            );
                          },
                          reservedSize: 32.w,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: const Color(0xFFE2E8F0).withOpacity(0.5),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    barGroups: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isTouched = index == touchedIndex;
                      
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: item.value * _animation.value,
                            color: isTouched 
                                ? item.color.withOpacity(0.8)
                                : item.color,
                            width: isTouched ? 22.w : 18.w,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6.r),
                              topRight: Radius.circular(6.r),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 20,
                              color: const Color(0xFFF1F5F9),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'Data driven from student requests',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialData {
  final String name;
  final double value;
  final Color color;

  MaterialData(this.name, this.value, this.color);
}