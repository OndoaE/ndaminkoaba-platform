import { IsInt, Max, Min } from 'class-validator';

export class GradeReviewDto {
  // SM-2 recall-quality grade: 0-2 = forgotten/hard, 3-5 = recalled with
  // increasing ease. The Practice screen's Again/Hard/Good/Easy buttons map
  // to 0/2/4/5.
  @IsInt()
  @Min(0)
  @Max(5)
  grade: number;
}
