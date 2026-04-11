<template>
  <LayoutWrapper>
    <div class="min-h-screen bg-gray-50">

      <!-- ===== STEP HEADER (tampil saat step > 0) ===== -->
      <div v-if="jadwalStore.currentStep > 0" class="bg-white border-b border-gray-200 px-4 md:px-8 py-4 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div class="flex items-center gap-2 md:gap-4">
          <button @click="jadwalStore.cancelAdd"
            class="flex items-center gap-2 text-gray-600 hover:text-gray-900 text-xs md:text-sm font-medium">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
            </svg>
            Kembali
          </button>
          <div>
            <h2 class="text-base md:text-lg font-bold text-slate-900">Tambah Jadwal Obat</h2>
            <p class="text-xs text-gray-500">Isi formulir untuk jadwal minum obat</p>
          </div>
        </div>

        <!-- Stepper -->
        <div class="flex items-center gap-1 md:gap-2 overflow-x-auto">
          <div v-for="(step, i) in jadwalStore.steps" :key="i" class="flex items-center gap-2">
            <div class="flex items-center gap-1 md:gap-2 flex-shrink-0">
              <div :class="[
                'w-6 h-6 md:w-7 md:h-7 rounded-full flex items-center justify-center text-xs font-bold transition-all flex-shrink-0',
                jadwalStore.currentStep > i + 1  ? 'bg-teal-600 text-white' :
                jadwalStore.currentStep === i + 1 ? 'bg-teal-600 text-white ring-2 md:ring-4 ring-teal-100' :
                'bg-gray-200 text-gray-500'
              ]">
                <svg v-if="jadwalStore.currentStep > i + 1" class="w-3 h-3 md:w-4 md:h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                </svg>
                <span v-else>{{ i + 1 }}</span>
              </div>
              <span :class="[
                'text-xs md:text-sm font-medium hidden md:inline',
                jadwalStore.currentStep >= i + 1 ? 'text-teal-600' : 'text-gray-400'
              ]">{{ step }}</span>
            </div>
            <div v-if="i < jadwalStore.steps.length - 1"
              :class="['w-8 md:w-12 h-0.5 flex-shrink-0', jadwalStore.currentStep > i + 1 ? 'bg-teal-600' : 'bg-gray-200']">
            </div>
          </div>
        </div>
      </div>

      <!-- ===== STEP 1 ===== -->
      <Step1PasienObat
        v-if="jadwalStore.currentStep === 1"
        :form="jadwalStore.form"
        :pasien-list="jadwalStore.filteredPasien"
        :search-pasien="jadwalStore.searchPasien"
        :selected-pasien-name="jadwalStore.getSelectedPasienName()"
        :selected-pasien-code="jadwalStore.getSelectedPasienCode()"
        :selected-pasien-diagnosa="jadwalStore.getSelectedPasienDiagnosa()"
        @update:form="jadwalStore.form = $event"
        @update:searchPasien="jadwalStore.searchPasien = $event"
        @select-pasien="jadwalStore.selectPasien"
        @next="jadwalStore.goToStep2"
        @cancel="jadwalStore.cancelAdd"
      />

      <!-- ===== STEP 2 ===== -->
      <Step2AturanMinum
        v-if="jadwalStore.currentStep === 2"
        :form="jadwalStore.form"
        :selected-pasien-name="jadwalStore.getSelectedPasienName()"
        :selected-pasien-code="jadwalStore.getSelectedPasienCode()"
        :selected-waktu-minum="jadwalStore.selectedWaktuMinum"
        :waktu-minum="jadwalStore.wakteMinum"
        :aturan-konsumsi="jadwalStore.aturanKonsumsi"
        @update:form="jadwalStore.form = $event"
        @toggle-waktu="jadwalStore.toggleWaktuMinum"
        @back="jadwalStore.currentStep = 1"
        @next="jadwalStore.goToStep3"
      />

      <!-- ===== STEP 3 ===== -->
      <Step3Konfirmasi
        v-if="jadwalStore.currentStep === 3"
        :form="jadwalStore.form"
        :selected-pasien-name="jadwalStore.getSelectedPasienName()"
        :selected-waktu-minum="jadwalStore.selectedWaktuMinum"
        :pasien-jadwal-list="jadwalStore.jadwalList.filter(j => j.pasien_nama === jadwalStore.getSelectedPasienName()).slice(0, 3)"
        @back-to-list="jadwalStore.cancelAdd"
        @add-another="jadwalStore.openAddSchedule"
      />

      <!-- ===== MAIN LIST ===== -->
      <JadwalTable
        v-if="jadwalStore.currentStep === 0"
        :jadwal-list="jadwalStore.filteredJadwalList"
        :search-query="jadwalStore.searchQuery"
        @update:searchQuery="jadwalStore.searchQuery = $event"
        @open-add="jadwalStore.openAddSchedule"
        @delete="jadwalStore.deleteJadwal"
      />

    </div>
  </LayoutWrapper>
</template>

<script>
import { onMounted } from 'vue'
import LayoutWrapper from '../../components/LayoutWrapper.vue'
import JadwalTable from './components/JadwalTable.vue'
import Step1PasienObat from './components/step1pasienobat.vue'
import Step2AturanMinum from './components/step2aturanminum.vue'
import Step3Konfirmasi from './components/step3konfirmasi.vue'
import { useJadwalStore } from '../../stores/jadwal'
import { usePasienStore } from '../../stores/pasien'

export default {
  name: 'JadwalView',
  components: {
    LayoutWrapper,
    JadwalTable,
    Step1PasienObat,
    Step2AturanMinum,
    Step3Konfirmasi,
  },
  setup() {
    const jadwalStore = useJadwalStore()
    const pasienStore = usePasienStore()

    onMounted(() => {
      jadwalStore.fetchJadwals()
      pasienStore.fetchPasiens()
    })

    return {
      jadwalStore,
      pasienStore,
    }
  },
}
</script>