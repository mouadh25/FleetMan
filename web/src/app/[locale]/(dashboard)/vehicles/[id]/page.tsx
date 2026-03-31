'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { createClient } from '@/lib/supabase/client';
import { SupabaseVehicleRepository } from '@/lib/repositories/supabase-vehicle-repository';
import type { Vehicle } from '@/lib/repositories/vehicle-repository';
import styles from '../vehicles.module.css';
import dashStyles from '../../dashboard.module.css';

/**
 * Vehicle Detail Card — displays full vehicle information organized into
 * three sections: Vehicle Info, Operational Data, and Legal Documents.
 * Legal document expiry dates are color-coded:
 *   🟢 > 30 days | 🟠 ≤ 30 days | 🔴 expired
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
   * Fetches an individual vehicle by its ID from the repository.
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
      case 'active':
        return t('statusActive');
      case 'in_maintenance':
        return t('statusInMaintenance');
      case 'out_of_service':
        return t('statusOutOfService');
      default:
        return status;
    }
  };

  const getStatusClass = (status: string) => {
    switch (status) {
      case 'active':
        return styles.statusActive;
      case 'in_maintenance':
        return styles.statusMaintenance;
      case 'out_of_service':
        return styles.statusOut;
      default:
        return '';
    }
  };

  const getFuelLabel = (fuel: string) => {
    switch (fuel) {
      case 'diesel':
        return t('fuelDiesel');
      case 'essence_sans_plomb':
        return t('fuelEssence');
      case 'sirghaz_gplc':
        return t('fuelSirghaz');
      default:
        return fuel;
    }
  };

  /**
   * Returns a color-coded expiry badge based on days remaining.
   * @param dateStr ISO date string for the expiry date
   * @returns JSX element with styled badge
   */
  const renderExpiryBadge = (dateStr: string | null) => {
    if (!dateStr) return <span style={{ color: '#9ca3af' }}>—</span>;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const expiry = new Date(dateStr);
    expiry.setHours(0, 0, 0, 0);
    const diffMs = expiry.getTime() - today.getTime();
    const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
      return (
        <span className={`${styles.expiryBadge} ${styles.expiryDanger}`}>
          🔴 {t('expired')}
        </span>
      );
    }

    if (diffDays <= 30) {
      return (
        <span className={`${styles.expiryBadge} ${styles.expiryWarning}`}>
          🟠 {diffDays} {t('odometerUnit') === 'km' ? 'j' : 'ي'}
        </span>
      );
    }

    return (
      <span className={`${styles.expiryBadge} ${styles.expiryOk}`}>
        🟢 {expiry.toLocaleDateString()}
      </span>
    );
  };

  if (loading) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center' }}>{tc('loading')}</div>
    );
  }

  if (!vehicle) {
    return <div className={styles.notFound}>{tc('noResults')}</div>;
  }

  return (
    <div>
      {/* ── Header ── */}
      <div className={styles.detailHeader}>
        <Link href="/vehicles" className={styles.backLink}>
          ←
        </Link>
        <h1 className={dashStyles.pageTitle} style={{ margin: 0 }}>
          {vehicle.plate_number}
        </h1>
        <div className={styles.detailActions}>
          <span
            className={`${styles.statusBadge} ${getStatusClass(vehicle.status)}`}
          >
            {getStatusLabel(vehicle.status)}
          </span>
        </div>
      </div>

      {/* ── Detail Grid ── */}
      <div className={styles.detailGrid}>
        {/* Card 1: Vehicle Information */}
        <div className={styles.detailCard}>
          <h2 className={styles.detailCardTitle}>{t('vehicleInfo')}</h2>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('plateNumber')}</span>
            <span className={styles.detailValue}>{vehicle.plate_number}</span>
          </div>

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
            <span className={styles.detailLabel}>{t('vinNumber')}</span>
            <span className={styles.detailValue}>
              {vehicle.vin || '—'}
            </span>
          </div>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('fuelType')}</span>
            <span className={styles.detailValue}>
              {getFuelLabel(vehicle.fuel_type)}
            </span>
          </div>
        </div>

        {/* Card 2: Operational Data */}
        <div className={styles.detailCard}>
          <h2 className={styles.detailCardTitle}>{t('operationalInfo')}</h2>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('odometer')}</span>
            <span className={styles.detailValue}>
              {vehicle.odometer_km.toLocaleString()} {t('odometerUnit')}
            </span>
          </div>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('assignedDriver')}</span>
            <span className={styles.detailValue}>
              {vehicle.assigned_driver_id ? vehicle.assigned_driver_id : t('noDriver')}
            </span>
          </div>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('costPerKm')}</span>
            <span className={styles.detailValue}>—</span>
          </div>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('totalCost')}</span>
            <span className={styles.detailValue}>—</span>
          </div>
        </div>

        {/* Card 3: Legal Documents */}
        <div className={`${styles.detailCard} ${styles.detailCardFull}`}>
          <h2 className={styles.detailCardTitle}>{t('legalDocuments')}</h2>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('insuranceExpiry')}</span>
            <span className={styles.detailValue}>
              {renderExpiryBadge(vehicle.insurance_expiry)}
            </span>
          </div>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('technicalInspection')}</span>
            <span className={styles.detailValue}>
              {renderExpiryBadge(vehicle.technical_inspection_expiry)}
            </span>
          </div>

          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('circulationCard')}</span>
            <span className={styles.detailValue}>
              {renderExpiryBadge(vehicle.circulation_card_expiry)}
            </span>
          </div>
        </div>

        {/* Card 4: Recent Activity (placeholder for Phase 3+) */}
        <div className={`${styles.detailCard} ${styles.detailCardFull}`}>
          <h2 className={styles.detailCardTitle}>{t('recentActivity')}</h2>
          <div className={styles.emptyState} style={{ padding: '2rem' }}>
            <p style={{ margin: 0 }}>{t('noActivity')}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
