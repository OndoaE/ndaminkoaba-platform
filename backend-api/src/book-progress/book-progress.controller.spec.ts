import { UserRole } from '@prisma/client';

import { BookProgressController } from './book-progress.controller';

const LEARNER = {
  userId: 'learner-1',
  email: 'l@x.com',
  role: UserRole.LEARNER,
};
const TEACHER = {
  userId: 'teacher-1',
  email: 't@x.com',
  role: UserRole.TEACHER,
};
const OTHER_USER = '11111111-1111-4111-8111-111111111111';
const BOOK = '22222222-2222-4222-8222-222222222222';

describe('BookProgressController ownership', () => {
  let service: { recordProgress: jest.Mock; findAll: jest.Mock };
  let controller: BookProgressController;

  beforeEach(() => {
    service = { recordProgress: jest.fn(), findAll: jest.fn() };
    controller = new BookProgressController(service as never);
  });

  it('forces a learner to record progress for themselves, ignoring a userId in the body', () => {
    controller.recordProgress(LEARNER, {
      userId: OTHER_USER,
      bookId: BOOK,
      lastPageNumber: 3,
    });
    expect(service.recordProgress).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'learner-1' }),
    );
  });

  it('forces a learner to read only their own progress, ignoring a userId query', () => {
    controller.findAll(LEARNER, { userId: OTHER_USER } as never);
    expect(service.findAll).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'learner-1' }),
    );
  });

  it('lets staff act on behalf of another user', () => {
    controller.recordProgress(TEACHER, {
      userId: OTHER_USER,
      bookId: BOOK,
      lastPageNumber: 3,
    });
    expect(service.recordProgress).toHaveBeenCalledWith(
      expect.objectContaining({ userId: OTHER_USER }),
    );

    controller.findAll(TEACHER, { userId: OTHER_USER } as never);
    expect(service.findAll).toHaveBeenCalledWith(
      expect.objectContaining({ userId: OTHER_USER }),
    );
  });
});
