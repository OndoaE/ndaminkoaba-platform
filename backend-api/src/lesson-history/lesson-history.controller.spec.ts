import { UserRole } from '@prisma/client';

import { LessonHistoryController } from './lesson-history.controller';

const LEARNER = {
  userId: 'learner-1',
  email: 'l@x.com',
  role: UserRole.LEARNER,
};
const ADMIN = { userId: 'admin-1', email: 'a@x.com', role: UserRole.ADMIN };
const OTHER_USER = '11111111-1111-4111-8111-111111111111';
const LESSON = '33333333-3333-4333-8333-333333333333';

describe('LessonHistoryController ownership', () => {
  let service: { recordView: jest.Mock; findAllForUser: jest.Mock };
  let controller: LessonHistoryController;

  beforeEach(() => {
    service = { recordView: jest.fn(), findAllForUser: jest.fn() };
    controller = new LessonHistoryController(service as never);
  });

  it('forces a learner to record views for themselves, ignoring a userId in the body', () => {
    controller.recordView(LEARNER, { userId: OTHER_USER, lessonId: LESSON });
    expect(service.recordView).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'learner-1' }),
    );
  });

  it("never returns another user's history to a learner", () => {
    controller.findAll(LEARNER, { userId: OTHER_USER } as never);
    expect(service.findAllForUser).toHaveBeenCalledWith(
      expect.objectContaining({ userId: 'learner-1' }),
    );
  });

  it('lets an admin read any user’s history', () => {
    controller.findAll(ADMIN, { userId: OTHER_USER } as never);
    expect(service.findAllForUser).toHaveBeenCalledWith(
      expect.objectContaining({ userId: OTHER_USER }),
    );
  });
});
