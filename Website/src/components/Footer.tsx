import Container from "./Container";

export default function Footer() {
  return (
    <footer className="border-t border-border py-8">
      <Container>
        <div className="flex flex-col gap-4 xs:flex-row xs:items-center xs:justify-between">
          <p className="text-[13px] text-muted">
            Built with React + Vite + Tailwind.
          </p>
          <div className="flex flex-wrap items-center gap-x-5 gap-y-2">
            <a
              href="#"
              className="text-[13px] text-muted no-underline transition-colors duration-150 hover:text-ink"
            >
              Documentation
            </a>
            <a
              href="#"
              className="text-[13px] text-muted no-underline transition-colors duration-150 hover:text-ink"
            >
              GitHub
            </a>
          </div>
        </div>
      </Container>
    </footer>
  );
}
