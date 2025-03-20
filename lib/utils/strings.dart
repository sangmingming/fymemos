extension StringExtension on String {
  String get id {
    return contains("/") ? split("/").last : this;
  }
}
