'use client';

import { useState, useEffect } from 'react';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { createClient } from '@/lib/supabase/client';
import { SupabaseVehicleRepository } from '@/lib/repositories/supabase-vehicle-repository';
import type { Vehicle } from '@/lib/repositories/vehicle-repository';
import styles from './vehicles.module.css';
import dashStyles from '../dashboard.module.css';

/**
 * Displays a list of all vehicles assigned to the current user's workspace.
 * Provides search capability and filtering by vehicle status.
 * @returns React component
 */
export default function VehiclesPage() {
  const t = useTranslations('Vehicles');
  const tc = useTranslations('Common');
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadVehicles();
  }, []);

  /**
   * Loads the vehicles from the repository.
   */
  const loadVehicles = async () => {
    try {
      const supabase = createClient();
      const repo = new SupabaseVehicleRepository(supabase);
      const data = await repo.getAll();
      setVehicles(data);
    } catch (err) {
      console.error('Failed to load vehicles:', err);
    } finally {
      setLoading(false);
    }
  };

  const filtered = vehicles.filter((v) => {
    const matchesSearch =
      v.plate_number.toLowerCase().includes(search.toLowerCase()) ||
      v.make.toLowerCase().includes(search.toLowerCase()) ||
      v.model.toLowerCase().includes(search.toLowerCase());
    const matchesStatus = !statusFilter || v.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusClass = (status: string) => {
    switch (status) {
      case 'active': return styles.statusActive;
      case 'in_maintenance': return styles.statusMaintenance;
      case 'out_of_service': return styles.statusOut;
      default: return '';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'active': return t('statusActive');
      case 'in_maintenance': return t('statusInMaintenance');
      case 'out_of_service': return t('statusOutOfService');
      default: return status;
    }
  };

  if (loading) {
    return <div style={{ padding: '2rem', textAlign: 'center' }}>{tc('loading')}</div>;
  }

  return (
    <div>
      <div className={styles.vehiclesHeader}>
        <h1 className={dashStyles.pageTitle}>{t('title')}</h1>
        <Link href="/vehicles/new" className={styles.addButton}>
          + {t('addVehicle')}
        </Link>
      </div>

      <div className={styles.toolbar}>
        <input
          type="text"
          placeholder={tc('search')}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className={styles.searchInput}
        />
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className={styles.filterSelect}
        >
          <option value="">{t('allStatuses')}</option>
          <option value="active">{t('statusActive')}</option>
          <option value="in_maintenance">{t('statusInMaintenance')}</option>
          <option value="out_of_service">{t('statusOutOfService')}</option>
        </select>
      </div>

      {filtered.length === 0 ? (
        <div className={styles.emptyState}>
          <div className={styles.emptyIcon}>🚚</div>
          <div className={styles.emptyTitle}>{t('noVehicles')}</div>
          <p>{t('addFirstVehicle')}</p>
        </div>
      ) : (
        <div className={styles.vehicleGrid}>
          {filtered.map((vehicle) => (
            <Link
              key={vehicle.id}
              href={`/vehicles/${vehicle.id}` as any}
              className={styles.vehicleCard}
            >
              <div className={styles.cardHeader}>
                <span className={styles.plateNumber}>{vehicle.plate_number}</span>
                <span className={`${styles.statusBadge} ${getStatusClass(vehicle.status)}`}>
                  {getStatusLabel(vehicle.status)}
                </span>
              </div>
              <div className={styles.cardBody}>
                <div className={styles.cardRow}>
                  <span className={styles.cardLabel}>{t('make')} / {t('model')}</span>
                  <span className={styles.cardValue}>{vehicle.make} {vehicle.model}</span>
                </div>
                <div className={styles.cardRow}>
                  <span className={styles.cardLabel}>{t('odometer')}</span>
                  <span className={styles.cardValue}>
                    {vehicle.odometer_km.toLocaleString()} {t('odometerUnit')}
                  </span>
                </div>
                <div className={styles.cardRow}>
                  <span className={styles.cardLabel}>{t('year')}</span>
                  <span className={styles.cardValue}>{vehicle.year}</span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
