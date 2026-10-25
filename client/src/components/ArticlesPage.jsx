import { useEffect, useState } from 'react';
import { getArticles } from '../data/articlesStore';

export default function ArticlesPage({ onNavigate }) {
  const [articles, setArticles] = useState([]);

  useEffect(() => {
    setArticles(getArticles());
  }, []);

  return (
    <div className="main-content">
      <div className="page-header">
        <p className="section-meta">Original Content</p>
        <h2 className="section-title" style={{ marginBottom: '0.25rem' }}>Articles & Critique</h2>
        <p style={{ color: 'var(--color-text-muted)', fontSize: '0.9rem', marginBottom: '2rem' }}>
          In-depth analysis, cinema trends, and guides from the thiraipedia editorial team.
        </p>
        <button className="btn btn-ghost" style={{ marginBottom: '1.5rem' }} onClick={() => onNavigate('articles-admin')}>Manage Articles</button>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
        {articles.map(article => (
          <article key={article.id} className="glass-panel" style={{ padding: '1.5rem 1.75rem', cursor: 'pointer', transition: 'var(--transition-smooth)' }}
            onClick={() => onNavigate('article', { articleId: article.id })}
            onMouseEnter={e => e.currentTarget.style.borderColor = 'var(--color-border-glow)'}
            onMouseLeave={e => e.currentTarget.style.borderColor = 'var(--color-border)'}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '1rem', flexWrap: 'wrap' }}>
              <div style={{ flex: 1, minWidth: '200px' }}>
                <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center', marginBottom: '0.5rem', flexWrap: 'wrap' }}>
                  <span style={{ fontSize: '0.7rem', padding: '0.15rem 0.5rem', borderRadius: '4px', background: 'rgba(251,191,36,0.1)', color: 'var(--color-accent-gold)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                    {article.category}
                  </span>
                  <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>{article.date}</span>
                  <span style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)' }}>· {article.readTime}</span>
                </div                <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem', lineHeight: 1.3, color: 'var(--color-text-main)' }}>
                  {article.title}
                </h3>
                <p style={{ fontSize: '0.9rem', color: 'var(--color-text-muted)', lineHeight: 1.6 }}>
                  {article.excerpt}
                </p>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', color: 'var(--color-accent-gold)', fontSize: '0.85rem', fontWeight: 600, whiteSpace: 'nowrap', flexShrink: 0 }}>
                Read More →
              </div>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}