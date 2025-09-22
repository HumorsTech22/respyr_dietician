abstract class HelpCenterState {}

class HelpCenterInitial extends HelpCenterState {}

class HelpCenterLoaded extends HelpCenterState {
  final List<String> faqs;
  final List<bool> expandedFaqs;

  HelpCenterLoaded({required this.faqs, required this.expandedFaqs});

  HelpCenterLoaded copyWith({List<bool>? expandedFaqs}) {
    return HelpCenterLoaded(
      faqs: faqs,
      expandedFaqs: expandedFaqs ?? this.expandedFaqs,
    );
  }
}

class HelpCenterIssue extends HelpCenterState {
  final List<String> selectedIssue;
  final int tabIndex;

  HelpCenterIssue({required this.selectedIssue, required this.tabIndex});

  HelpCenterIssue copyWith({List<String>? selectedIssue, int? tabIndex}) {
    return HelpCenterIssue(
      selectedIssue: selectedIssue ?? this.selectedIssue,
      tabIndex: tabIndex ?? this.tabIndex,
    );
  }
}
