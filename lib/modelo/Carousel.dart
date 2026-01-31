
class Carousel {
  int index;
  String title;
  String image;
  bool isSelected;

  Carousel({required this.index,required this.title,required this.image,required this.isSelected});
}

List<Carousel> carousel =[
  Carousel(index: 0, title: "CAFES", image: "assets/images/banner.jpg", isSelected: true),
  Carousel(index: 1, title: "POSTRES", image: "assets/images/banner.jpg", isSelected: false),
  Carousel(index: 2, title: "FRAPPES", image: "assets/images/banner.jpg", isSelected: false),
  Carousel(index: 3, title: "SMOOTHIES", image: "assets/images/banner.jpg", isSelected: false),
  Carousel(index: 4, title: "TES", image: "assets/images/banner.jpg", isSelected: false),
  Carousel(index: 5, title: "TISANA", image: "assets/images/banner.jpg", isSelected: false),

];