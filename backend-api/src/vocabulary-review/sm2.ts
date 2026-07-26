export interface Sm2State {
  easeFactor: number;
  intervalDays: number;
  repetitions: number;
}

/// Canonical SM-2 spaced-repetition update. `grade` is a 0-5 recall-quality
/// score (below 3 = forgotten, resets the schedule; 3+ = recalled,
/// advances it and raises the ease factor for very easy recalls).
export function applySm2(state: Sm2State, grade: number): Sm2State {
  if (grade < 3) {
    return {
      easeFactor: state.easeFactor,
      intervalDays: 1,
      repetitions: 0,
    };
  }

  let intervalDays: number;
  if (state.repetitions === 0) {
    intervalDays = 1;
  } else if (state.repetitions === 1) {
    intervalDays = 6;
  } else {
    intervalDays = Math.round(state.intervalDays * state.easeFactor);
  }

  const easeFactor = Math.max(
    1.3,
    state.easeFactor + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02)),
  );

  return {
    easeFactor,
    intervalDays,
    repetitions: state.repetitions + 1,
  };
}
