class HelpCenterFaqQuest {
  final String question;
  final String answer;

  HelpCenterFaqQuest({required this.question, required this.answer});
}

final List<HelpCenterFaqQuest> faqItems = [
  HelpCenterFaqQuest(
    question: "1. Device not connecting issue?",
    answer: "Check your Bluetooth connection and restart the device.",
  ),
  HelpCenterFaqQuest(
    question: "2. How to add new profile?",
    answer: "Go to Profile → Add Profile → Fill in the details.",
  ),
  HelpCenterFaqQuest(
    question: "3. How switch from one profile to another?",
    answer:
        "Logout and login with another profile or use the Switch Profile option in settings.",
  ),
];
