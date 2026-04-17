'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/lib/supabase/client';
import { useTranslations } from 'next-intl';
import styles from '../dashboard.module.css';

interface UserProfile {
  id: string;
  email: string;
  full_name: string | null;
  roles: string[];
  created_at: string;
}

export default function AdminPanel() {
  const t = useTranslations('Admin');
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchUsers() {
      const supabase = createClient();
      const { data, error } = await supabase
        .from('profiles')
        .select('id, email, full_name, roles, created_at')
        .order('created_at', { ascending: false });

      if (error) {
        setError(error.message);
      } else {
        setUsers(data || []);
      }
      setLoading(false);
    }

    fetchUsers();
  }, []);

  const getRoleBadgeClass = (roles: string[]) => {
    if (roles.includes('ceo')) return styles.roleBadgeCeo;
    if (roles.includes('admin')) return styles.roleBadgeAdmin;
    if (roles.includes('gatekeeper')) return styles.roleBadgeGatekeeper;
    if (roles.includes('mechanic')) return styles.roleBadgeMechanic;
    if (roles.includes('driver')) return styles.roleBadgeDriver;
    if (roles.includes('park_manager')) return styles.roleBadgeParkManager;
    return styles.roleBadgeDefault;
  };

  const formatRole = (roles: string[]) => {
    if (roles.includes('ceo')) return 'CEO';
    if (roles.includes('admin')) return 'Admin';
    if (roles.includes('gatekeeper')) return 'Gardien';
    if (roles.includes('mechanic')) return 'Mécanicien';
    if (roles.includes('driver')) return 'Chauffeur';
    if (roles.includes('park_manager')) return 'Gestionnaire';
    return roles.join(', ');
  };

  if (loading) {
    return (
      <div className={styles.dashboardContent}>
        <div className={styles.emptyState}>
          <span>⏳</span>
          <p>Chargement...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.dashboardContent}>
        <div className={styles.emptyState}>
          <span>❌</span>
          <p>{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.dashboardContent}>
      <header className={styles.pageHeader}>
        <div>
          <h1 className={styles.pageTitle}>{t('title')}</h1>
          <p className={styles.pageSubtitle}>{t('subtitle')}</p>
        </div>
        <div className={styles.headerActions}>
          <span className={styles.userCount}>
            {users.length} utilisateur{users.length !== 1 ? 's' : ''}
          </span>
        </div>
      </header>

      <div className={styles.adminTable}>
        <div className={styles.tableHeader}>
          <div className={styles.tableCell}>Utilisateur</div>
          <div className={styles.tableCell}>Email</div>
          <div className={styles.tableCell}>Rôle</div>
          <div className={styles.tableCell}>Date d'inscription</div>
        </div>

        {users.length === 0 ? (
          <div className={styles.emptyState}>
            <span>👥</span>
            <p>Aucun utilisateur trouvé</p>
          </div>
        ) : (
          users.map((user) => (
            <div key={user.id} className={styles.tableRow}>
              <div className={styles.tableCell}>
                <div className={styles.userInfo}>
                  <span className={styles.userAvatar}>
                    {user.full_name?.charAt(0) || user.email.charAt(0).toUpperCase()}
                  </span>
                  <span className={styles.userName}>
                    {user.full_name || 'Sans nom'}
                  </span>
                </div>
              </div>
              <div className={styles.tableCell}>
                <span className={styles.userEmail}>{user.email}</span>
              </div>
              <div className={styles.tableCell}>
                <span className={`${styles.roleBadge} ${getRoleBadgeClass(user.roles)}`}>
                  {formatRole(user.roles)}
                </span>
              </div>
              <div className={styles.tableCell}>
                <span className={styles.userDate}>
                  {new Date(user.created_at).toLocaleDateString('fr-DZ')}
                </span>
              </div>
            </div>
          ))
        )}
      </div>

      <section className={styles.adminInfo}>
        <div className={styles.infoCard}>
          <h3 className={styles.infoTitle}>ℹ️ À propos des rôles</h3>
          <ul className={styles.infoList}>
            <li><strong>CEO:</strong> Accès complet au tableau de bord et aux rapports</li>
            <li><strong>Admin:</strong> Gestion des utilisateurs et des véhicules</li>
            <li><strong>Gardien:</strong> Effectuer les audits à l'entrée/sortie</li>
            <li><strong>Mécanicien:</strong> Gérer les travaux de maintenance</li>
            <li><strong>Chauffeur:</strong> Voir les ordres de mission</li>
            <li><strong>Gestionnaire:</strong> Gérer le parc et les affectations</li>
          </ul>
        </div>
      </section>
    </div>
  );
}
