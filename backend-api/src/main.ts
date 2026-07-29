import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { json, urlencoded } from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Express's default JSON body limit (100kb) is far too small for a
  // whole-book USFM import (Ewondo + English text for every verse of a
  // book easily exceeds that) — raised so /bible-verses/bulk and similar
  // bulk-content endpoints don't 500 on large-but-legitimate payloads.
  app.use(json({ limit: '25mb' }));
  app.use(urlencoded({ limit: '25mb', extended: true }));

  // Exposed so browser-side PDF/EPUB viewers (which read these headers via
  // JS to drive ranged/partial fetches) can see them on cross-origin
  // /uploads responses — the CORS-safelisted header set doesn't include
  // Content-Range or Accept-Ranges by default.
  //
  // CORS_ORIGINS is a comma-separated allowlist (e.g. the deployed web app's
  // origin) for production; left unset, all origins are allowed, which is
  // fine for local development and short-lived tunnel-based testing but
  // should be set before this is a long-lived public deployment.
  const corsOrigins = process.env.CORS_ORIGINS?.split(',')
    .map((o) => o.trim())
    .filter(Boolean);
  app.enableCors({
    origin: corsOrigins && corsOrigins.length > 0 ? corsOrigins : true,
    exposedHeaders: ['Content-Range', 'Accept-Ranges', 'Content-Length'],
  });
  // Default Helmet policy is same-origin, which silently blocks the web
  // build's <audio>/<img> tags from loading /uploads files as plain media
  // resources whenever the Flutter web app and the API are on different
  // origins (always true here — separate ports in dev, separate domains
  // over the tunnels used for testing). CORS above already governs which
  // origins may read these responses, so this header is redundant with (and
  // stricter than) that policy — cross-origin is the correct setting for an
  // API that's meant to be consumed from a separate frontend origin.
  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
  app.use(morgan('dev'));

  app.setGlobalPrefix('api');

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(new ResponseInterceptor());

  const config = new DocumentBuilder()
    .setTitle('NdaMinkoaba API')
    .setDescription('AI-assisted indigenous language learning platform API')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        in: 'header',
      },
      'access-token',
    )
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT ?? 3000;
  await app.listen(port);

  console.log(`🚀 NdaMinkoaba API running on http://localhost:${port}`);
}

bootstrap();