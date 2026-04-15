import Container from "./Container";

interface NavLink {
  label: string;
  href: string;
}

export default function Nav({ links }: { links?: NavLink[] }) {
  return (
    <nav className="border-b border-border py-6">
      <Container>
        <div className="flex items-center justify-between">
          <a
            href="/"
            className="text-[15px] font-semibold tracking-[-0.01em] text-ink no-underline"
          >
            MuseAmp
          </a>
          {links && links.length > 0 && (
            <ul className="flex list-none gap-7">
              {links.map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    className="text-sm text-muted no-underline transition-colors duration-150 hover:text-ink"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          )}
        </div>
      </Container>
    </nav>
  );
}
