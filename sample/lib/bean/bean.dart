///https://javiercbk.github.io/json_to_dart/ use this website to decode json string

class GetSampleBean {
  Rating? rating;
  String? subtitle;
  List<String>? author;

  GetSampleBean({this.rating, this.subtitle, this.author});

  GetSampleBean.fromJson(Map<String, dynamic> json) {
    rating = Rating.fromJson(json['rating']);
    subtitle = json['subtitle'];
    author = json['author'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rating != null) {
      data['rating'] = this.rating?.toJson();
    }
    data['subtitle'] = this.subtitle;
    data['author'] = this.author;
    return data;
  }
}

class Rating {
  int? max;
  int? numRaters;
  String? average;
  int? min;

  Rating({this.max, this.numRaters, this.average, this.min});

  Rating.fromJson(Map<String, dynamic> json) {
    max = json['max'];
    numRaters = json['numRaters'];
    average = json['average'];
    min = json['min'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['max'] = this.max;
    data['numRaters'] = this.numRaters;
    data['average'] = this.average;
    data['min'] = this.min;
    return data;
  }
}
