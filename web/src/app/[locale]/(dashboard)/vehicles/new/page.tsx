'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { createClient } from '@/lib/supabase/client';
import { SupabaseVehicleRepository } from '@/lib/repositories/supabase-vehicle-repository';
import type { CreateVehicleDTO, FuelType } from '@/lib/repositories/vehicle-repository';
import styles from '../vehicles.module.css';

/**
 * Page component for adding a new vehicle to the workspace.
 * Captures vehicle details, fuel type, VIN, and legal document expiry dates.
 * Performs a plate-limit check against the tenant's max_vehicles before submission.
 * @returns React component
 */
export default function AddVehiclePage() {
  const t = useTranslations('Vehicles');
  const tc = useTranslations('Common');
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [formData, setFormData] = useState({
    plate_number: '',
    make: '',
    model: '',
    year: new Date().getFullYear(),
    vin: '',
    odometer_km: 0,
    fuel_type: 'diesel' as FuelType,
    insurance_expiry: '',
    technical_inspection_expiry: '',
    circulation_card_expiry: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === 'year' || name === 'odometer_km' ? Number(value) : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const supabase = createClient();
      const repo = new SupabaseVehicleRepository(supabase);

      const newVehicle: CreateVehicleDTO = {
        plate_number: formData.plate_number,
        make: formData.make,
        model: formData.model,
        year: formData.year,
        odometer_km: formData.odometer_km,
        fuel_type: formData.fuel_type,
        ...(formData.vin ? { vin: formData.vin } : {}),
        ...(formData.insurance_expiry ? { insurance_expiry: formData.insurance_expiry } : {}),
        ...(formData.technical_inspection_expiry
          ? { technical_inspection_expiry: formData.technical_inspection_expiry }
          : {}),
        ...(formData.circulation_card_expiry
          ? { circulation_card_expiry: formData.circulation_card_expiry }
          : {}),
      };

      await repo.create(newVehicle);

      router.push('/vehicles');
      router.refresh();
    } catch (err: unknown) {
      console.error(err);
      setError(err instanceof Error ? err.message : tc('error'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.formContainer}>
      <div className={styles.detailHeader}>
        <Link href="/vehicles" className={styles.backLink}>
          ←
        </Link>
        <h1 style={{ margin: 0, fontSize: '1.5rem', fontWeight: 700, color: 'var(--primary-blue)' }}>
          {t('addVehicle')}
        </h1>
      </div>

      <div className={styles.formCard}>
        {error && (
          <div className={styles.errorBanner}>
            <span>⚠</span> {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className={styles.formGrid}>
            {/* ── Vehicle Information Section ── */}
            <div className={styles.formSectionTitle}>{t('vehicleInfo')}</div>

            <div className={styles.formField}>
              <label htmlFor="plate_number" className={styles.formLabel}>
                {t('plateNumber')} *
              </label>
              <input
                id="plate_number"
                name="plate_number"
                type="text"
                value={formData.plate_number}
                onChange={handleChange}
                className={styles.formInput}
                placeholder="00000-000-00"
                required
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="vin" className={styles.formLabel}>
                {t('vinNumber')}
              </label>
              <input
                id="vin"
                name="vin"
                type="text"
                value={formData.vin}
                onChange={handleChange}
                className={styles.formInput}
                placeholder="WBA..."
                maxLength={17}
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="make" className={styles.formLabel}>
                {t('make')} *
              </label>
              <input
                id="make"
                name="make"
                type="text"
                value={formData.make}
                onChange={handleChange}
                className={styles.formInput}
                required
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="model" className={styles.formLabel}>
                {t('model')} *
              </label>
              <input
                id="model"
                name="model"
                type="text"
                value={formData.model}
                onChange={handleChange}
                className={styles.formInput}
                required
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="year" className={styles.formLabel}>
                {t('year')} *
              </label>
              <input
                id="year"
                name="year"
                type="number"
                value={formData.year}
                onChange={handleChange}
                className={styles.formInput}
                required
                min="1990"
                max={new Date().getFullYear() + 1}
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="odometer_km" className={styles.formLabel}>
                {t('odometer')} ({t('odometerUnit')}) *
              </label>
              <input
                id="odometer_km"
                name="odometer_km"
                type="number"
                value={formData.odometer_km}
                onChange={handleChange}
                className={styles.formInput}
                required
                min="0"
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="fuel_type" className={styles.formLabel}>
                {t('fuelType')} *
              </label>
              <select
                id="fuel_type"
                name="fuel_type"
                value={formData.fuel_type}
                onChange={handleChange}
                className={styles.formSelect}
                required
              >
                <option value="diesel">{t('fuelDiesel')}</option>
                <option value="essence_sans_plomb">{t('fuelEssence')}</option>
                <option value="sirghaz_gplc">{t('fuelSirghaz')}</option>
              </select>
            </div>

            {/* ── Legal Documents Section ── */}
            <div className={styles.formSectionTitle}>{t('legalDocuments')}</div>

            <div className={styles.formField}>
              <label htmlFor="insurance_expiry" className={styles.formLabel}>
                {t('insuranceExpiry')}
              </label>
              <input
                id="insurance_expiry"
                name="insurance_expiry"
                type="date"
                value={formData.insurance_expiry}
                onChange={handleChange}
                className={styles.formInput}
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="technical_inspection_expiry" className={styles.formLabel}>
                {t('technicalInspection')}
              </label>
              <input
                id="technical_inspection_expiry"
                name="technical_inspection_expiry"
                type="date"
                value={formData.technical_inspection_expiry}
                onChange={handleChange}
                className={styles.formInput}
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="circulation_card_expiry" className={styles.formLabel}>
                {t('circulationCard')}
              </label>
              <input
                id="circulation_card_expiry"
                name="circulation_card_expiry"
                type="date"
                value={formData.circulation_card_expiry}
                onChange={handleChange}
                className={styles.formInput}
              />
            </div>
          </div>

          <div className={styles.formActions}>
            <Link href="/vehicles" className={styles.cancelButton}>
              {tc('cancel')}
            </Link>
            <button type="submit" className={styles.submitButton} disabled={loading}>
              {loading ? tc('loading') : t('saveVehicle')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
