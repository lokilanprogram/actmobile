  final List<Event> events = [
    Event('Семья', 'assets/events/family.svg'),
    Event('Спорт', 'assets/events/sport.svg'),
    Event('Красота', 'assets/events/beauty.svg'),
    Event('Видеоигры', 'assets/events/games.svg'),
    Event('Мода', 'assets/events/fashion.svg'),
    Event('Танцы', 'assets/events/dance.svg'),
    Event('Технологии', 'assets/events/tech.svg'),
    Event('Наука', 'assets/events/science.svg'),
    Event('Еда', 'assets/events/food.svg'),
    Event('Культура', 'assets/events/culture.svg'),
    Event('Музыка', 'assets/events/music.svg'),
    Event('Кино', 'assets/events/movie.svg'),
    Event('Образование', 'assets/events/education.svg'),
    Event('Юмор', 'assets/events/humour.svg'),
    Event('Транспорт', 'assets/events/transport.svg'),
    Event('Развлечения', 'assets/events/entertain.svg'),
    Event('Животные', 'assets/events/animals.svg'),
    Event('Творчество', 'assets/events/art.svg'),
    Event('Здоровье', 'assets/events/health.svg'),
    Event('Бизнес', 'assets/events/business.svg'),
    Event('Путешествия', 'assets/events/travel.svg'),
  ];

  class Event {
  final String name;
  final String iconPath;

  Event(this.name, this.iconPath);
}