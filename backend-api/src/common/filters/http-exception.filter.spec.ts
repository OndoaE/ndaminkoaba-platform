import { BadRequestException } from '@nestjs/common';

import { HttpExceptionFilter } from './http-exception.filter';

function run(exception: unknown) {
  const json = jest.fn();
  const status = jest.fn().mockReturnValue({ json });
  const host = {
    switchToHttp: () => ({
      getResponse: () => ({ status }),
      getRequest: () => ({ url: '/x' }),
    }),
  };
  jest.spyOn(console, 'error').mockImplementation(() => undefined);
  new HttpExceptionFilter().catch(exception, host as never);
  return { status: status.mock.calls[0][0], body: json.mock.calls[0][0] };
}

describe('HttpExceptionFilter', () => {
  afterEach(() => jest.restoreAllMocks());

  it('reports body-parser "payload too large" as 413, not 500', () => {
    const tooLarge = Object.assign(new Error('request entity too large'), {
      status: 413,
      expose: true,
    });
    expect(run(tooLarge).status).toBe(413);
  });

  it('reports malformed JSON as 400, not 500', () => {
    const bad = Object.assign(new SyntaxError('Unexpected token'), {
      status: 400,
      expose: true,
    });
    expect(run(bad).status).toBe(400);
  });

  it('still treats unknown errors as an opaque 500', () => {
    const out = run(new Error('db password is hunter2'));
    expect(out.status).toBe(500);
    expect(JSON.stringify(out.body)).not.toContain('hunter2');
  });

  it('does not trust a 4xx status on an error that is not marked safe to expose', () => {
    expect(
      run(Object.assign(new Error('internal detail'), { status: 400 })).status,
    ).toBe(500);
  });

  it('keeps Nest HttpExceptions as they were', () => {
    expect(run(new BadRequestException('nope')).status).toBe(400);
  });
});
