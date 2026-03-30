'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { createClient } from '@/lib/supabase/client';
import { SupabaseAuthRepository } from '@/lib/repositories/supabase-auth-repository';
import styles from './register.module.css';

export default function RegisterPage() {
  const t = useTranslations('Auth');
  const tc = useTranslations('Common');
  const router = useRouter();
  
  const [fullName, setFullName] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const supabase = createClient();
      const authRepo = new SupabaseAuthRepository(supabase);
      await authRepo.signUp(email, password, fullName, companyName);
      
      // On success, redirect to dashboard
      router.push('/');
      router.refresh();
    } catch (err: any) {
      console.error('Registration error:', err);
      setError(err?.message || t('registerError'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.card}>
        <div className={styles.logoSection}>
          <div className={styles.logoIcon}>🚛</div>
          <h1 className={styles.title}>{t('registerTitle')}</h1>
          <p className={styles.subtitle}>{t('registerSubtitle')}</p>
        </div>

        <form onSubmit={handleRegister} className={styles.form}>
          <div className={styles.field}>
            <label htmlFor="companyName" className={styles.label}>{t('companyNameLabel')}</label>
            <input
              id="companyName"
              type="text"
              value={companyName}
              onChange={(e) => setCompanyName(e.target.value)}
              className={styles.input}
              required
            />
          </div>

          <div className={styles.field}>
            <label htmlFor="fullName" className={styles.label}>{t('fullNameLabel')}</label>
            <input
              id="fullName"
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className={styles.input}
              required
            />
          </div>

          <div className={styles.field}>
            <label htmlFor="email" className={styles.label}>{t('emailLabel')}</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className={styles.input}
              required
              autoComplete="email"
            />
          </div>

          <div className={styles.field}>
            <label htmlFor="password" className={styles.label}>{t('passwordLabel')}</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={styles.input}
              required
              autoComplete="new-password"
            />
          </div>

          {error && <p className={styles.error}>{error}</p>}

          <button
            type="submit"
            className={styles.button}
            disabled={loading}
          >
            {loading ? tc('loading') : t('registerButton')}
          </button>
        </form>

        <div className={styles.links}>
          <span>{t('hasAccount')}</span>
          <Link href="/login" className={styles.linkButton}>
            {t('loginLink')}
          </Link>
        </div>
      </div>
    </div>
  );
}
