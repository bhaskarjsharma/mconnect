
class NewsContent{
  final int contentId;
  final String contentType;
  final String contentTitle;
  final String contentDescription;

  NewsContent({required this.contentId, required this.contentType, required this.contentTitle,required this.contentDescription});
  factory NewsContent.fromJson(Map<String, dynamic> json) {
    return NewsContent(
      contentId: json['ContentID'],
      contentType: json['contentType'],
      contentTitle: json['title'],
      contentDescription: json['description'],
    );
  }
}