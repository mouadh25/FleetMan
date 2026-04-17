'use client';

import { usePathname, useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { createClient } from '@/lib/supabase/client';
import styles from '../dashboard.module.css';

interface SidebarProps {
  userName: string;
}

const navItems = [
  { key: 'dashboard', icon: '📊', href: '/' },
  { key: 'vehicles', icon: '🚚', href: '/vehicles' },
  { key: 'maintenance', icon: '🔧', href: '/maintenance' },
  { key: 'reports', icon: '📈', href: '/reports' },
  { key: 'admin', icon: '👥', href: '/admin' },
  { key: 'settings', icon: '⚙️', href: '/settings' },
];

/**
 * Sidebar component that provides main navigation.
 * 
 * @param {SidebarProps} props - The component props containing user details.
 * @returns React component
 */
export function Sidebar({ userName }: SidebarProps) {
  const t = useTranslations('Nav');
  const tc = useTranslations('Common');
  const pathname = usePathname();
  const router = useRouter();

  const handleSignOut = async () => {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push('/login');
    router.refresh();
  };

  return (
    <aside className={styles.sidebar}>
      <div className={styles.sidebarHeader}>
        <div className={styles.sidebarLogo}>
          <span className={styles.sidebarLogoIcon}>🚛</span>
          <span className={styles.sidebarLogoText}>FleetMan</span>
        </div>
        <div className={styles.sidebarUser}>{userName}</div>
      </div>

      <nav className={styles.sidebarNav}>
        {navItems.map((item) => {
          const isActive =
            item.href === '/'
              ? pathname === '/' || pathname.endsWith('/fr-DZ') || pathname.endsWith('/ar-DZ')
              : pathname.includes(item.href);

          return (
            <Link
              key={item.key}
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              href={item.href as any}
              className={`${styles.navLink} ${isActive ? styles.navLinkActive : ''}`}
            >
              <span className={styles.navIcon}>{item.icon}</span>
              {t(item.key as Parameters<typeof t>[0])}
            </Link>
          );
        })}
      </nav>

      <div className={styles.sidebarFooter}>
        <button onClick={handleSignOut} className={styles.signOutButton}>
          <span className={styles.navIcon}>🚪</span>
          {tc('signOut')}
        </button>
      </div>
    </aside>
  );
}
