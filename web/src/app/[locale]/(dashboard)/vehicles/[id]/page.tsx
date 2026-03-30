'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { createClient } from '@/lib/supabase/client';
import { SupabaseVehicleRepository } from '@/lib/repositories/supabase-vehicle-repository';
import type { Vehicle } from '@/lib/repositories/vehicle-repository';
import styles from '../vehicles.module.css';

/**
 * Displays detailed information about a specific vehicle.
 * @returns React component
 */
export default function VehicleDetailPage() {
  const t = useTranslations('Vehicles');
  const tc = useTranslations('Common');
  const params = useParams();
  
  const [vehicle, setVehicle] = useState<Vehicle | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (params.id) {
      loadVehicle(params.id as string);
    }
  }, [params.id]);

  /**
   * Fetches an individual vehicle by its ID.
   * @param id The vehicle UUID
   */
  const loadVehicle = async (id: string) => {
    try {
      const supabase = createClient();
      const repo = new SupabaseVehicleRepository(supabase);
      const data = await repo.getById(id);
      setVehicle(data);
    } catch (err) {
      console.error('Failed to load vehicle:', err);
    } finally {
      setLoading(false);
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

  const getStatusClass = (status: string) => {
    switch (status) {
      case 'active': return styles.statusActive;
      case 'in_maintenance': return styles.statusMaintenance;
      case 'out_of_service': return styles.statusOut;
      default: return '';
    }
  };

  if (loading) {
    return <div style={{ padding: '2rem', textAlign: 'center' }}>{tc('loading')}</div>;
  }

  if (!vehicle) {
    return (
      <div className={styles.notFound}>
        {tc('notFound')}
      </div>
    );
  }

  return (
    <div>
      <div className={styles.detailHeader}>
        <Link href="/vehicles" className={styles.backLink}>
          ←
        </Link>
        <h1 className={styles.pageTitle} style={{ margin: 0 }}>
          {vehicle.plate_number}
        </h1>
        <span className={`${styles.statusBadge} ${getStatusClass(vehicle.status)}`} style={{ marginLeft: 'auto' }}>
          {getStatusLabel(vehicle.status)}
        </span>
      </div>

      <div className={styles.detailGrid}>
        <div className={styles.detailCard}>
          <h2 className={styles.detailCardTitle}>{t('vehicleDetails')}</h2>
          
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('make')}</span>
            <span className={styles.detailValue}>{vehicle.make}</span>
          </div>
          
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('model')}</span>
            <span className={styles.detailValue}>{vehicle.model}</span>
          </div>
          
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('year')}</span>
            <span className={styles.detailValue}>{vehicle.year}</span>
          </div>
          
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('odometer')}</span>
            <span className={styles.detailValue}>{vehicle.odometer_km.toLocaleString()} {t('odometerUnit')}</span>
          </div>
        </div>

        <div className={styles.detailCard}>
          <h2 className={styles.detailCardTitle}>{t('recentActivity')}</h2>
          <div className={styles.emptyState} style={{ padding: '2rem' }}>
            <p style={{ margin: 0 }}>{t('noActivity')}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
