# Domínio: Security

Itens exemplo para checklist de qualidade de requisitos de segurança.

## Autenticação

- São requisitos de autenticação especificados para todos os recursos protegidos? [Cobertura]
- Política de senha é definida (tamanho, complexidade, histórico)? [Clareza]
- MFA é requerido para operações sensíveis? [Cobertura]
- Comportamento em tentativas falhas (lockout, captcha) é especificado? [Completude]

## Autorização e Acesso

- Modelo de autorização (RBAC, ABAC) é documentado? [Completude]
- Requisitos de deny-by-default estão explícitos? [Spec §FR-X]
- Escalação de privilégios tem trilha de auditoria? [Cobertura]

## Proteção de Dados

- São requisitos de proteção de dados definidos para informações sensíveis? [Completude]
- Dados em repouso são criptografados (campos sensíveis, banco)? [Clareza]
- Dados em trânsito usam TLS com versões mínimas especificadas? [Clareza]
- Retenção e descarte de dados têm política definida? [Cobertura, Compliance]

## Input Validation

- Requisitos de validação de input são definidos para todos os endpoints? [Cobertura]
- Sanitização contra injection (SQL, XSS, command) está especificada? [Completude]
- Tamanho máximo de payloads é definido? [Clareza]

## Logging e Auditoria

- Eventos de segurança (login, acesso negado, mudança de permissão) são logados? [Cobertura]
- Logs contêm dados suficientes para forensics sem vazar segredos? [Clareza]
- Política de retenção de logs atende compliance? [Compliance]

## Secrets e Credenciais

- Secrets não ficam em código/config versionado (vault, env vars)? [Completude]
- Rotação de secrets tem processo definido? [Gap]
- Chaves de API e tokens têm escopo mínimo (least privilege)? [Clareza]

## Threat Modeling

- O modelo de ameaças está documentado e requisitos alinhados a ele? [Traceability]
- Vetores de ataque conhecidos para o domínio foram considerados? [Cobertura]

## Compliance

- Requisitos de LGPD/GDPR/PCI/HIPAA aplicáveis são mapeados? [Compliance]
- Direito de consentimento e remoção de dados, onde aplicável, é definido? [Compliance]
