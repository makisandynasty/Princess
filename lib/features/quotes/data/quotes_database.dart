import '../domain/entities/quote_entity.dart';

class QuotesDatabase {
  QuotesDatabase._();

  static final List<QuoteEntity> allQuotes = [
    // ── Motivational ──
    const QuoteEntity(
      id: 1,
      text: "The secret of getting ahead is getting started.",
      author: "Mark Twain",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 2,
      text: "Small daily improvements over time lead to stunning results.",
      author: "Robin Sharma",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 3,
      text: "Action is the foundational key to all success.",
      author: "Pablo Picasso",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 4,
      text: "Believe you can and you're halfway there.",
      author: "Theodore Roosevelt",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 5,
      text: "Do what you can, with what you have, where you are.",
      author: "Theodore Roosevelt",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 6,
      text: "Focus on being productive instead of busy.",
      author: "Tim Ferriss",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 7,
      text: "The best way to predict your future is to create it.",
      author: "Peter Drucker",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 8,
      text: "Every accomplishment starts with the decision to try.",
      author: "John F. Kennedy",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 9,
      text: "Your time is limited, don't waste it living someone else's life.",
      author: "Steve Jobs",
      category: "Motivational",
    ),
    const QuoteEntity(
      id: 10,
      text: "Discipline is the bridge between goals and accomplishment.",
      author: "Jim Rohn",
      category: "Motivational",
    ),

    // ── Affectionate & Uplifting ──
    const QuoteEntity(
      id: 11,
      text: "Every morning is a fresh start and a new chance to shine, Princess.",
      author: "Daily Affirmation",
      category: "Affectionate",
    ),
    const QuoteEntity(
      id: 12,
      text: "You are capable of far more than you realize. Have a magnificent day!",
      author: "Princess Companion",
      category: "Affectionate",
    ),
    const QuoteEntity(
      id: 13,
      text: "Smile in the mirror. You bring so much light and grace to this world.",
      author: "Yoko Ono",
      category: "Affectionate",
    ),
    const QuoteEntity(
      id: 14,
      text: "Wear your crown of confidence today and let your brilliance lead.",
      author: "Royal Affirmation",
      category: "Affectionate",
    ),
    const QuoteEntity(
      id: 15,
      text: "You are strong, you are kind, and you are unstoppable.",
      author: "Gentle Reminder",
      category: "Affectionate",
    ),
    const QuoteEntity(
      id: 16,
      text: "Take a deep breath. You are doing wonderfully well.",
      author: "Mindful Heart",
      category: "Affectionate",
    ),
    const QuoteEntity(
      id: 17,
      text: "May your day be filled with warm smiles, quiet courage, and joyful wins.",
      author: "Princess Wish",
      category: "Affectionate",
    ),
    const QuoteEntity(
      id: 18,
      text: "Be proud of how far you have come and excited for how far you will go.",
      author: "Daily Reflection",
      category: "Affectionate",
    ),

    // ── Mindfulness & Serenity ──
    const QuoteEntity(
      id: 19,
      text: "Peace comes from within. Do not seek it without.",
      author: "Buddha",
      category: "Mindfulness",
    ),
    const QuoteEntity(
      id: 20,
      text: "Breathe in calm, breathe out tension.",
      author: "Mindful Living",
      category: "Mindfulness",
    ),
    const QuoteEntity(
      id: 21,
      text: "Wherever you are, be there totally.",
      author: "Eckhart Tolle",
      category: "Mindfulness",
    ),
    const QuoteEntity(
      id: 22,
      text: "In the middle of difficulty lies opportunity.",
      author: "Albert Einstein",
      category: "Mindfulness",
    ),
    const QuoteEntity(
      id: 23,
      text: "Quiet the mind and the soul will speak.",
      author: "Ma Jaya Sati Bhagavati",
      category: "Mindfulness",
    ),
    const QuoteEntity(
      id: 24,
      text: "Surrender to what is. Let go of what was. Have faith in what will be.",
      author: "Sonia Ricotti",
      category: "Mindfulness",
    ),
    const QuoteEntity(
      id: 25,
      text: "The present moment is filled with joy and happiness. If you are attentive, you will see it.",
      author: "Thich Nhat Hanh",
      category: "Mindfulness",
    ),

    // ── Gratitude ──
    const QuoteEntity(
      id: 26,
      text: "Gratitude turns what we have into enough.",
      author: "Aesop",
      category: "Gratitude",
    ),
    const QuoteEntity(
      id: 27,
      text: "When you are grateful, fear disappears and abundance appears.",
      author: "Tony Robbins",
      category: "Gratitude",
    ),
    const QuoteEntity(
      id: 28,
      text: "Acknowledging the good you already have is the foundation for all abundance.",
      author: "Eckhart Tolle",
      category: "Gratitude",
    ),
    const QuoteEntity(
      id: 29,
      text: "Start each day with a positive thought and a grateful heart.",
      author: "Roy T. Bennett",
      category: "Gratitude",
    ),
    const QuoteEntity(
      id: 30,
      text: "Happiness cannot be traveled to, owned, earned, or worn. It is the spiritual experience of living every minute with love, grace, and gratitude.",
      author: "Denis Waitley",
      category: "Gratitude",
    ),

    // ── Focus & Discipline ──
    const QuoteEntity(
      id: 31,
      text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
      author: "Will Durant",
      category: "Discipline",
    ),
    const QuoteEntity(
      id: 32,
      text: "Do something today that your future self will thank you for.",
      author: "Sean Patrick Flanery",
      category: "Discipline",
    ),
    const QuoteEntity(
      id: 33,
      text: "It does not matter how slowly you go as long as you do not stop.",
      author: "Confucius",
      category: "Discipline",
    ),
    const QuoteEntity(
      id: 34,
      text: "Energy flows where attention goes.",
      author: "Tony Robbins",
      category: "Discipline",
    ),
    const QuoteEntity(
      id: 35,
      text: "Champions keep playing until they get it right.",
      author: "Billie Jean King",
      category: "Discipline",
    ),
  ];
}
