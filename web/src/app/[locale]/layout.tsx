import type { Metadata } from 'next';
import { Inter, Noto_Sans_Arabic } from 'next/font/google';
import { NextIntlClientProvider, hasLocale } from 'next-intl';
import { getMessages, getTranslations } from 'next-intl/server';
import { notFound } from 'next/navigation';
import { routing } from '@/i18n/routing';
import '../globals.css';

const inter = Inter({ subsets: ['latin'], variable: '--font-inter' });
const notoSansArabic = Noto_Sans_Arabic({ subsets: ['arabic'], variable: '--font-noto-arabic' });

type LayoutProps = {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
};

export async function generateMetadata(
  { params }: LayoutProps
): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'Index' });

  return {
    title: t('title'),
    description: 'FleetMan — Système de Gestion de Flotte',
  };
}

export default async function RootLayout({ children, params }: LayoutProps) {
  const { locale } = await params;

  if (!hasLocale(routing.locales, locale)) {
    notFound();
  }

  const messages = await getMessages();
  const dir = locale === 'ar-DZ' ? 'rtl' : 'ltr';
  const fontClass = locale === 'ar-DZ' ? notoSansArabic.className : inter.className;

  return (
    <html lang={locale} dir={dir}>
      <body className={fontClass}>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
