export default function App() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-bg px-6 text-center">
      <div className="flex flex-col items-center gap-10">
        <img
          src="/app-icon.png"
          alt="MuseAmp"
          className="h-32 w-32 object-contain"
        />
        <div>
          <h1 className="mb-3 text-[32px] font-semibold tracking-[-0.02em] text-ink">
            MuseAmp
          </h1>
          <p className="text-[15px] text-muted">
            A simple music player for your own library.
          </p>
        </div>
      </div>

      <div className="absolute bottom-8 text-[13px] text-muted">
        © 2026 MuseAmp. All rights reserved.
      </div>
    </div>
  );
}
