# Backend-driven UI для Avito — динамический интерфейс: изменяйте экраны и элементы без обновления приложения 🚀

<!-- Language Switcher -->
<div align="right">
  <select onchange="switchLanguage(this.value)">
    <option value="ru">🇷🇺 Русский</option>
    <option value="en">🇬🇧 English</option>
  </select>
</div>

<script>
function switchLanguage(lang) {
  if (lang === 'en') {
    window.location.hash = 'en';
    document.documentElement.lang = 'en';
  } else {
    window.location.hash = 'ru';
    document.documentElement.lang = 'ru';
  }
}

// Check hash on load
if (window.location.hash === '#en') {
  document.querySelector('select').value = 'en';
  document.documentElement.lang = 'en';
}
</script>

---

## Содержание / Table of Contents

- [Обзор / Overview](#обзор--overview)
- [Функциональность и Технологии / Features & Tech Stack](#функциональность-и-технологии--features--tech-stack)
- [Установка / Installation](#установка--installation)
- [Использование / Usage](#использование--usage)
- [Участие в разработке / Contributing](#участие-в-разработке--contributing)
- [Лицензия / License](#лицензия--license)

---

## Обзор / Overview <a id="обзор--overview"></a>

<div lang="ru">
Данный подход позволяет Avito динамически управлять макетами экранов и контентом напрямую с сервера, без необходимости обновления приложения. Это обеспечивает мгновенное A/B-тестирование, персонализированный пользовательский опыт и быстрое развертывание новых функций или промо-баннеров. В результате создается более гибкая и data-driven платформа, которая может адаптироваться в реальном времени к поведению пользователей и рыночным тенденциям.
</div>

<div lang="en" style="display: none;">
This approach enables Avito to dynamically control screen layouts and content directly from the server, without requiring app updates. It allows for instant A/B testing, personalized user experiences, and rapid deployment of new features or promotional banners. Ultimately, this creates a more agile and data-driven platform that can adapt in real-time to user behavior and market trends.
</div>
