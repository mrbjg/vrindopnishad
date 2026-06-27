import React from 'react';
import { Link } from '@/lib/router-compat';

import Image from 'next/image';

interface AuthorCardProps {
  name: string;
  role?: string;
  bio?: string;
  imageUrl?: string;
  slug?: string;
  isEditorialBoard?: boolean;
}

export default function AuthorCard({
  name,
  role = 'Archival Scholar',
  bio,
  imageUrl,
  slug,
  isEditorialBoard = false
}: AuthorCardProps) {
  const authorLink = slug ? `/saints/${slug}` : (isEditorialBoard ? '/editorial-policy' : '/author');

  return (
    <div className="p-5 border border-white/5 rounded-2xl bg-white/[0.01] flex flex-col sm:flex-row items-center sm:items-start gap-4 mt-8">
      {imageUrl ? (
        <Image
          src={imageUrl}
          alt={name}
          width={56}
          height={56}
          className="w-14 h-14 rounded-full object-cover border border-white/10 shrink-0"
        />
      ) : (
        <div className="w-14 h-14 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400 font-serif text-xl shrink-0 select-none">
          {name.charAt(0)}
        </div>
      )}
      <div className="text-center sm:text-left flex-1">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-1 mb-1.5">
          <Link href={authorLink} className="text-sm font-semibold hover:text-amber-400 transition-colors font-serif text-white/90">
            {name}
          </Link>
          <span className="text-[10px] font-medium tracking-wide bg-amber-500/10 text-amber-400 px-2 py-0.5 rounded-full self-center sm:self-auto select-none">
            {role}
          </span>
        </div>
        {bio ? (
          <p className="text-[11px] leading-relaxed text-white/50">{bio}</p>
        ) : (
          <p className="text-[11px] leading-relaxed text-white/50">
            Verified by the Vrindopnishad Manuscript Archiving Board. Committed to preserving the theological integrity and historical lineage of classical Braj literature.
          </p>
        )}
      </div>
    </div>
  );
}
