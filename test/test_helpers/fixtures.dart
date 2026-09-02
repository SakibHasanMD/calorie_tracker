// Shared sample domain objects so every test file builds on the same fixtures.
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';

/// A seeded (non-custom) gram-based food.
const sampleSeedGramFood = Food(
  id: 'seed_0001',
  name: 'White rice (cooked)',
  category: 'Grains',
  measurementType: MeasurementType.gram,
  caloriesPerGram: 1.3,
  caloriesPerPiece: null,
);

/// A seeded (non-custom) piece-based food.
const sampleSeedPieceFood = Food(
  id: 'seed_0002',
  name: 'Egg (large)',
  category: 'Protein',
  measurementType: MeasurementType.piece,
  caloriesPerGram: null,
  caloriesPerPiece: 72,
);

/// A custom user-added food.
const sampleCustomFood = Food(
  id: 'custom_abc',
  name: 'Protein shake',
  category: 'Protein',
  measurementType: MeasurementType.gram,
  caloriesPerGram: 0.9,
  caloriesPerPiece: null,
  isCustom: true,
);