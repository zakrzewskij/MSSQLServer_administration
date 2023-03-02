--1
--Pełna kopia zapasowa bazy
BACKUP DATABASE AdventureWorks2019 TO DISK = 'E:\Backups\AdventureWorks2019_full_compression.bak' WITH COMPRESSION,
FORMAT,
INIT;

--2
--Różnicowa kopia zapasowa
BACKUP DATABASE AdventureWorks2019 TO DISK = 'E:\Backups\AdventureWorks2019_full_differential_compression.bak' WITH COMPRESSION,
NOINIT,
DIFFERENTIAL;

--3
--Kopia logu transakcyjnego
BACKUP LOG AdventureWorks2019 TO DISK = 'E:\Backups\AdventureWorks2019_log_compression.bak' WITH COMPRESSION,
NOINIT;

--4
--Wystąpienie awarii serwera

--5
--Wykonanie kopii ogonka logu
BACKUP LOG AdventureWorks2019 TO DISK = 'E:\Backups\AdventureWorks2019_log_cae_compression_error.bak' WITH CONTINUE_AFTER_ERROR,
NORECOVERY;

--6
--Odtworzenie bazy z pełnej kopii zapasowej
RESTORE DATABASE AdventureWorks2019
FROM
    DISK = 'E:\Backups\AdventureWorks2019_full_compression.bak' WITH NORECOVERY;

--7
--Odtworzenie kopii różnicowej
RESTORE DATABASE AdventureWorks2019
FROM
    DISK = 'E:\Backups\AdventureWorks2019_full_differential_compression.bak' WITH NORECOVERY;

--8
--Odtworzenie kopii logu
RESTORE DATABASE AdventureWorks2019
FROM
    DISK = 'E:\Backups\AdventureWorks2019_log_compression.bak' WITH NORECOVERY;

--9
--Odtworzenie kopii ogonka logu
RESTORE DATABASE AdventureWorks2019
FROM
    DISK = 'E:\Backups\AdventureWorks2019_log_cae_compression_error.bak' WITH RECOVERY;