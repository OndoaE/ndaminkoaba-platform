import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { UpsertBibleBookCoverDto } from './dto/upsert-bible-book-cover.dto/upsert-bible-book-cover.dto';
import { UpsertBibleHeroImageDto } from './dto/upsert-bible-hero-image.dto/upsert-bible-hero-image.dto';

@Injectable()
export class BibleImagesService {
  constructor(private readonly prisma: PrismaService) {}

  async getImages(languageId?: string) {
    const [hero, covers] = await Promise.all([
      languageId
        ? this.prisma.bibleHeroImage.findUnique({ where: { languageId } })
        : null,
      this.prisma.bibleBookCover.findMany({
        where: { languageId },
        orderBy: { bookKey: 'asc' },
      }),
    ]);

    return { hero, covers };
  }

  upsertBookCover(dto: UpsertBibleBookCoverDto) {
    return this.prisma.bibleBookCover.upsert({
      where: {
        languageId_bookKey: {
          languageId: dto.languageId,
          bookKey: dto.bookKey,
        },
      },
      create: dto,
      update: { coverUrl: dto.coverUrl },
    });
  }

  upsertHeroImage(dto: UpsertBibleHeroImageDto) {
    return this.prisma.bibleHeroImage.upsert({
      where: { languageId: dto.languageId },
      create: dto,
      update: { imageUrl: dto.imageUrl },
    });
  }

  async removeBookCover(id: string) {
    const cover = await this.prisma.bibleBookCover.findUnique({ where: { id } });
    if (!cover) {
      throw new NotFoundException('Bible book cover not found.');
    }
    return this.prisma.bibleBookCover.delete({ where: { id } });
  }

  async removeHeroImage(id: string) {
    const hero = await this.prisma.bibleHeroImage.findUnique({ where: { id } });
    if (!hero) {
      throw new NotFoundException('Bible hero image not found.');
    }
    return this.prisma.bibleHeroImage.delete({ where: { id } });
  }
}
