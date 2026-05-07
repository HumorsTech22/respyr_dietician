abstract class ActivationCodeEvent {}

class ActivationCodeChanged extends ActivationCodeEvent {
  final String code;
  ActivationCodeChanged(this.code);
}

class SubmitActivationCode extends ActivationCodeEvent {}