'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { createClient } from '@/lib/supabase/client';
import { SupabaseVehicleRepository } from '@/lib/repositories/supabase-vehicle-repository';
import type { Vehicle } from '@/lib/repositories/vehicle-repository';
import styles from '../vehicles.module.css';

export default function AddVehiclePage() {
  const t = useTranslations('Vehicles');
  const tc = useTranslations('Common');
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [formData, setFormData] = useState<Partial<Vehicle>>({
    plate_number: '',
    make: '',
    model: '',
    year: new Date().getFullYear(),
    status: 'active',
    odometer_km: 0,
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
      
      // We need the user's workspace_id
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data: profile } = await supabase
        .from('profiles')
        .select('workspace_id')
        .eq('id', user.id)
        .single();
        
      if (!profile?.workspace_id) throw new Error('No workspace found');

      const repo = new SupabaseVehicleRepository(supabase);
      
      const newVehicle: Omit<Vehicle, 'id' | 'created_at' | 'updated_at'> = {
        workspace_id: profile.workspace_id,
        plate_number: formData.plate_number!,
        make: formData.make!,
        model: formData.model!,
        year: formData.year!,
        status: formData.status as any,
        odometer_km: formData.odometer_km!,
      };

      await repo.create(newVehicle);
      
      router.push('/vehicles');
      router.refresh();
    } catch (err: any) {
      console.error(err);
      setError(err.message || tc('errorGeneric'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.formContainer}>
      <div className={styles.detailHeader}>
        <a href="/vehicles" className={styles.backLink}>
          ←
        </a>
        <h1 className={styles.pageTitle} style={{ margin: 0 }}>{t('addVehicle')}</h1>
      </div>

      <div className={styles.formCard}>
        {error && <div style={{ color: 'red', marginBottom: '1rem' }}>{error}</div>}
        
        <form onSubmit={handleSubmit}>
          <div className={styles.formGrid}>
            <div className={styles.formField}>
              <label htmlFor="plate_number" className={styles.formLabel}>{t('plateNumber')}</label>
              <input
                id="plate_number"
                name="plate_number"
                type="text"
                value={formData.plate_number}
                onChange={handleChange}
                className={styles.formInput}
                required
              />
            </div>

            <div className={styles.formField}>
              <label htmlFor="status" className={styles.formLabel}>{t('status')}</label>
              <select
                id="status"
                name="status"
                value={formData.status}
                onChange={handleChange}
                className={styles.formSelect}
                required
              >
                <option value="active">{t('statusActive')}</option>
                <option value="in_maintenance">{t('statusInMaintenance')}</option>
                <option value="out_of_service">{t('statusOutOfService')}</option>
              </select>
            </div>

            <div className={styles.formField}>
              <label htmlFor="make" className={styles.formLabel}>{t('make')}</label>
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
              <label htmlFor="model" className={styles.formLabel}>{t('model')}</label>
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
              <label htmlFor="year" className={styles.formLabel}>{t('year')}</label>
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
              <label htmlFor="odometer_km" className={styles.formLabel}>{t('odometer')}</label>
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
          </div>

          <div className={styles.formActions}>
            <a href="/vehicles" className={styles.cancelButton}>
              {tc('cancel')}
            </a>
            <button type="submit" className={styles.submitButton} disabled={loading}>
              {loading ? tc('loading') : t('saveVehicle')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
