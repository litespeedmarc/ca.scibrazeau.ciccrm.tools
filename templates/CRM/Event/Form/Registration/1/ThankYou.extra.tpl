{literal}
    <script>
        CRM.$('td').each(function (el) {
            // remove time porition for this event.  It is variable based on option chosen
            var content = this.textContent;
            var idx = content.indexOf("2017  1:00 PM")
            if (idx > 0) {
                content = content.substring(0, idx) + "2017";
                this.textContent = content;
            }
        });
    </script>
{/literal}
