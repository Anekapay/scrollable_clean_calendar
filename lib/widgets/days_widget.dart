import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';

class DaysWidget extends StatelessWidget {
  final CleanCalendarController cleanCalendarController;
  final DateTime month;
  final double calendarCrossAxisSpacing;
  final double calendarMainAxisSpacing;
  final Layout? layout;
  final Widget Function(
    BuildContext context,
    DayValues values,
  )? dayBuilder;
  final Color? selectedBackgroundColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColorBetween;
  final Color? disableBackgroundColor;
  final double radius;
  final TextStyle? textStyle;

  const DaysWidget({
    Key? key,
    required this.month,
    required this.cleanCalendarController,
    required this.calendarCrossAxisSpacing,
    required this.calendarMainAxisSpacing,
    required this.layout,
    required this.dayBuilder,
    required this.selectedBackgroundColor,
    required this.backgroundColor,
    required this.selectedBackgroundColorBetween,
    required this.disableBackgroundColor,
    required this.radius,
    required this.textStyle,
  }) : super(key: key);

  /// Custom variable Kiosaneka
  static const Color _yesterdayColor = Color(0xFFC4C4C4);
  static const Color _todayBackgroundColor = Color(0xFFEEEEEF);

  @override
  Widget build(BuildContext context) {
    // Start weekday - Days per week - The first weekday of this month
    // 7 - 7 - 1 = -1 = 1
    // 6 - 7 - 1 = -2 = 2

    // What it means? The first weekday does not change, but the start weekday have changed,
    // so in the layout we need to change where the calendar first day is going to start.
    int monthPositionStartDay = (cleanCalendarController.weekdayStart -
            DateTime.daysPerWeek -
            DateTime(month.year, month.month).weekday)
        .abs();
    monthPositionStartDay = monthPositionStartDay > DateTime.daysPerWeek
        ? monthPositionStartDay - DateTime.daysPerWeek
        : monthPositionStartDay;

    final start = monthPositionStartDay == 7 ? 0 : monthPositionStartDay;

    // If the monthPositionStartDay is equal to 7, then in this layout logic will cause a trouble, beacause it will
    // have a line in blank and in this case 7 is the same as 0.

    return GridView.count(
      crossAxisCount: DateTime.daysPerWeek,
      physics: const NeverScrollableScrollPhysics(),
      addRepaintBoundaries: false,
      padding: EdgeInsets.zero,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      shrinkWrap: true,
      children: List.generate(
          DateTime(month.year, month.month + 1, 0).day + start, (index) {
        if (index < start) return const SizedBox.shrink();
        final day = DateTime(month.year, month.month, (index + 1 - start));
        final text = (index + 1 - start).toString();

        bool isSelected = false;

        if (cleanCalendarController.rangeMinDate != null) {
          if (cleanCalendarController.rangeMinDate != null &&
              cleanCalendarController.rangeMaxDate != null) {
            isSelected = day
                    .isSameDayOrAfter(cleanCalendarController.rangeMinDate!) &&
                day.isSameDayOrBefore(cleanCalendarController.rangeMaxDate!);
          } else {
            isSelected =
                day.isAtSameMomentAs(cleanCalendarController.rangeMinDate!);
          }
        }

        Widget widget;

        final dayValues = DayValues(
          day: day,
          isFirstDayOfWeek: day.weekday == cleanCalendarController.weekdayStart,
          isLastDayOfWeek: day.weekday == cleanCalendarController.weekdayEnd,
          isSelected: isSelected,
          maxDate: cleanCalendarController.maxDate,
          minDate: cleanCalendarController.minDate,
          text: text,
          selectedMaxDate: cleanCalendarController.rangeMaxDate,
          selectedMinDate: cleanCalendarController.rangeMinDate,
        );

        if (dayBuilder != null) {
          widget = dayBuilder!(context, dayValues);
        } else {
          widget = <Layout, Widget Function()>{
            Layout.DEFAULT: () => _beauty(context, dayValues),
            Layout.BEAUTY: () => _beauty(context, dayValues),
          }[layout]!();
        }

        return GestureDetector(
          onTap: () {
            if (day.isBefore(cleanCalendarController.minDate) &&
                !day.isSameDay(cleanCalendarController.minDate)) {
              if (cleanCalendarController.onPreviousMinDateTapped != null) {
                cleanCalendarController.onPreviousMinDateTapped!(day);
              }
            } else if (day.isAfter(cleanCalendarController.maxDate)) {
              if (cleanCalendarController.onAfterMaxDateTapped != null) {
                cleanCalendarController.onAfterMaxDateTapped!(day);
              }
            } else {
              if (!cleanCalendarController.readOnly) {
                cleanCalendarController.onDayClick(day);
              }
            }
          },
          child: widget,
        );
      }),
    );
  }

  Widget _beauty(BuildContext context, DayValues values) {
    BorderRadiusGeometry? borderRadius;
    Color bgColor = Colors.transparent;
    EdgeInsets margin = EdgeInsets.zero;
    TextStyle txtStyle = textStyle!;
    bool showSelectedMinDate = false;
    bool showSelectedMaxDate = false;
    bool isToday = false;

    if (values.isSelected) {
      if ((values.selectedMinDate != null &&
              values.day.isSameDay(values.selectedMinDate!)) ||
          (values.selectedMaxDate != null &&
              values.day.isSameDay(values.selectedMaxDate!))) {
        bgColor = selectedBackgroundColorBetween!;

        if (values.selectedMinDate == values.selectedMaxDate) {
          borderRadius = BorderRadius.circular(radius);
          margin = const EdgeInsets.symmetric(horizontal: 8);
          showSelectedMinDate = true;
        } else if (values.selectedMinDate != null &&
            values.day.isSameDay(values.selectedMinDate!)) {
          borderRadius = BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
          margin = const EdgeInsets.only(left: 8);
          showSelectedMinDate = true;
          txtStyle = textStyle!.copyWith(color: selectedBackgroundColorBetween);
        } else if (values.selectedMaxDate != null &&
            values.day.isSameDay(values.selectedMaxDate!)) {
          borderRadius = BorderRadius.only(
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
          margin = const EdgeInsets.only(right: 8);
          showSelectedMaxDate = true;
          txtStyle = textStyle!.copyWith(color: selectedBackgroundColorBetween);
        }
      } else {
        bgColor = selectedBackgroundColorBetween!;
      }
    } else if (values.day.isSameDay(values.minDate)) {
      isToday = true;
    } else if (values.day.isBefore(values.minDate) ||
        values.day.isAfter(values.maxDate)) {
      txtStyle = textStyle!.copyWith(color: _yesterdayColor);
    }

    return Stack(children: [
      Visibility(
        visible: isToday,
        child: _buildTodayContainer(values.text),
      ),
      Container(
        alignment: Alignment.center,
        margin: margin,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        height: 50,
        child: Text(
          values.text,
          textAlign: TextAlign.center,
          style: txtStyle,
        ),
      ),
      Visibility(
        visible: showSelectedMinDate || showSelectedMaxDate,
        child: _buildSelectedContainer(
          values.text,
          showSelectedMinDate,
          showSelectedMaxDate,
        ),
      ),
    ], alignment: Alignment.center);
  }

  _buildTodayContainer(String text) {
    return Stack(children: [
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _todayBackgroundColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        height: 50,
        width: 50,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
      Positioned(
        top: 7,
        child: Text(
          "Hari ini",
          style: textStyle!.copyWith(fontSize: 9),
        ),
      )
    ], alignment: Alignment.center);
  }

  _buildSelectedContainer(
    String text,
    bool showSelectedMinDate,
    bool showSelectedMaxDate,
  ) {
    return Stack(children: [
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedBackgroundColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        height: 50,
        width: 50,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle!.copyWith(color: Colors.white),
        ),
      ),
      Visibility(
        visible: showSelectedMinDate,
        child: Positioned(
          top: 7,
          child: Text(
            "Berangkat",
            style: textStyle!.copyWith(color: Colors.white, fontSize: 9),
          ),
        ),
      ),
      Visibility(
        visible: showSelectedMaxDate,
        child: Positioned(
          top: 7,
          child: Text(
            "Pulang",
            style: textStyle!.copyWith(color: Colors.white, fontSize: 9),
          ),
        ),
      )
    ], alignment: Alignment.center);
  }
}
