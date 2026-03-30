'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { createClient } from '@/lib/supabase/client';
import { SupabaseVehicleRepository } from '@/lib/repositories/supabase-vehicle-repository';
import styles from '../vehicles.module.css';
import dashStyles from '../../dashboard.module.css';

export default function AddVehiclePage() {
  const t = useTranslations('Vehicles');
  const tc = useTranslations('Common');
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [form, setForm] = useState({
    plate_number: '',
    make: '',
    model: '',
    year: new Date().getFullYear(),
    vin: '',
    fuel_type: 'diesel',
    odometer_km: 0,
    status: 'active',
  });

  const updateField = (field: string, value: string | number) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const supabase = createClient();
      const repo = new SupabaseVehicleRepository(supabase);
      await repo.create(form);
      router.push('/vehicles');
      router.refresh();
    } catch (err) {
      setError(tc('error'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.formContainer}>
      <h1 className={dashStyles.pageTitle}>{t('addVehicle')}</h1>

      <div className={styles.formCard}>
        <form onSubmit={handleSubmit}>
          <div className={styles.formGrid}>
            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('plateNumber')}</label>
              <input
                className={styles.formInput}
                value={form.plate_number}
                onChange={(e) => updateField('plate_number', e.target.value)}
                required
                placeholder="00000-000-00"
              />
            </div>

            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('vin')}</label>
              <input
                className={styles.formInput}
                value={form.vin}
                onChange={(e) => updateField('vin', e.target.value)}
                placeholder="VIN"
              />
            </div>

            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('make')}</label>
              <input
                className={styles.formInput}
                value={form.make}
                onChange={(e) => updateField('make', e.target.value)}
                required
                placeholder="Toyota, Hyundai..."
              />
            </div>

            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('model')}</label>
              <input
                className={styles.formInput}
                value={form.model}
                onChange={(e) => updateField('model', e.target.value)}
                required
                placeholder="Hilux, HD78..."
              />
            </div>

            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('year')}</label>
              <input
                type="number"
                className={styles.formInput}
                value={form.year}
                onChange={(e) => updateField('year', parseInt(e.target.value))}
                min={1990}
                max={2030}
                required
              />
            </div>

            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('fuelType')}</label>
              <select
                className={styles.formSelect}
                value={form.fuel_type}
                onChange={(e) => updateField('fuel_type', e.target.value)}
              >
                <option value="diesel">{t('fuelDiesel')}</option>
                <option value="gasoline">{t('fuelGasoline')}</option>
                <option value="electric">{t('fuelElectric')}</option>
                <option value="hybrid">{t('fuelHybrid')}</option>
              </select>
            </div>

            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('odometer')}</label>
              <input
                type="number"
                className={styles.formInput}
                value={form.odometer_km}
                onChange={(e) => updateField('odometer_km', parseInt(e.target.value))}
                min={0}
              />
            </div>

            <div className={styles.formField}>
              <label className={styles.formLabel}>{t('status')}</label>
              <select
                className={styles.formSelect}
                value={form.status}
                onChange={(e) => updateField('status', e.target.value)}
              >
                <option value="active">{t('statusActive')}</option>
                <option value="in_maintenance">{t('statusInMaintenance')}</option>
                <option value="out_of_service">{t('statusOutOfService')}</option>
              </select>
            </div>
          </div>

          {error && <p style={{ color: 'var(--error-red)', marginTop: '1rem' }}>{error}</p>}

          <div className={styles.formActions}>
            <a href="/vehicles" className={styles.cancelButton}>{tc('cancel')}</a>
            <button type="submit" className={styles.submitButton} disabled={loading}>
              {loading ? tc('loading') : tc('save')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
