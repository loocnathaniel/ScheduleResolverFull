class   ScheduleAnalysis {

  final String conflict;
  final String rankedTasks;
  final String recommendedSchedule;
  final String explanation;

  ScheduleAnalysis ({

    required this.conflict,
    required this.rankedTasks,
    required this.recommendedSchedule,
    required this.explanation,

  });
}