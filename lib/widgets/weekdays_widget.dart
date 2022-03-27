import 'package:flutter/material.dart';

import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';

class WeekdaysWidget extends StatelessWidget {
  final bool showWeekdays;
  final CleanCalendarController cleanCalendarController;
  final String locale;
  final Layout? layout;
  final TextStyle? textStyle;
  final Widget Function(BuildContext context, String weekday)? weekdayBuilder;

  const WeekdaysWidget({
    Key? key,
    required this.showWeekdays,
    required this.cleanCalendarController,
    required this.locale,
    required this.layout,
    required this.weekdayBuilder,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showWeekdays) return const SizedBox.shrink();

    return Column(children: [
      GridView.count(
        crossAxisCount: DateTime.daysPerWeek,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: List.generate(DateTime.daysPerWeek, (index) {
          final weekDay = cleanCalendarController.getDaysOfWeek(locale)[index];
          bool isSunday = index == 6 ? true : false;

          if (weekdayBuilder != null) {
            return weekdayBuilder!(context, weekDay);
          }

          return <Layout, Widget Function()>{
            Layout.DEFAULT: () => _beauty(context, weekDay, isSunday),
            Layout.BEAUTY: () => _beauty(context, weekDay, isSunday)
          }[layout]!();
        }),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(
          color: Color(0xFFD6D6D6),
          thickness: 1,
          height: 1,
        ),
      ),
    ]);
  }

  Widget _beauty(BuildContext context, String weekday, bool isSunday) {
    return Center(
      child: Text(
        weekday.capitalize(),
        style: textStyle!.copyWith(
          color: isSunday ? const Color(0xFFF01E1E) : const Color(0xFF898383),
        ),
      ),
    );
  }
}
