namespace vtys
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            btnEkle = new Button();
            btnSil = new Button();
            btnGuncelle = new Button();
            btnAra = new Button();
            btnListele = new Button();
            dataGridView1 = new DataGridView();
            txtFilmAdi = new TextBox();
            txtImdb = new TextBox();
            label1 = new Label();
            label2 = new Label();
            cmbKategori = new ComboBox();
            label3 = new Label();
            txtId = new TextBox();
            label4 = new Label();
            txtDuration = new TextBox();
            txtAra = new TextBox();
            label5 = new Label();
            label6 = new Label();
            btnIslem = new Button();
            btnKisiListele = new Button();
            ((System.ComponentModel.ISupportInitialize)dataGridView1).BeginInit();
            SuspendLayout();
            // 
            // btnEkle
            // 
            btnEkle.Location = new Point(1528, 247);
            btnEkle.Name = "btnEkle";
            btnEkle.Size = new Size(167, 59);
            btnEkle.TabIndex = 0;
            btnEkle.Text = "Ekle";
            btnEkle.UseVisualStyleBackColor = true;
            btnEkle.Click += btnEkle_Click;
            // 
            // btnSil
            // 
            btnSil.Location = new Point(1528, 318);
            btnSil.Name = "btnSil";
            btnSil.Size = new Size(167, 57);
            btnSil.TabIndex = 1;
            btnSil.Text = "Sil";
            btnSil.UseVisualStyleBackColor = true;
            btnSil.Click += btnSil_Click;
            // 
            // btnGuncelle
            // 
            btnGuncelle.Location = new Point(1528, 384);
            btnGuncelle.Name = "btnGuncelle";
            btnGuncelle.Size = new Size(167, 59);
            btnGuncelle.TabIndex = 2;
            btnGuncelle.Text = "Guncelle";
            btnGuncelle.UseVisualStyleBackColor = true;
            btnGuncelle.Click += btnGuncelle_Click;
            // 
            // btnAra
            // 
            btnAra.Location = new Point(1528, 449);
            btnAra.Name = "btnAra";
            btnAra.Size = new Size(167, 64);
            btnAra.TabIndex = 3;
            btnAra.Text = "Ara";
            btnAra.UseVisualStyleBackColor = true;
            btnAra.Click += btnAra_Click;
            // 
            // btnListele
            // 
            btnListele.Location = new Point(1528, 184);
            btnListele.Name = "btnListele";
            btnListele.Size = new Size(167, 57);
            btnListele.TabIndex = 4;
            btnListele.Text = "Filmleri Listele";
            btnListele.UseVisualStyleBackColor = true;
            btnListele.Click += btnListele_Click;
            // 
            // dataGridView1
            // 
            dataGridView1.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dataGridView1.Location = new Point(12, 12);
            dataGridView1.Name = "dataGridView1";
            dataGridView1.RowHeadersWidth = 62;
            dataGridView1.Size = new Size(1110, 517);
            dataGridView1.TabIndex = 5;
            dataGridView1.CellContentClick += dataGridView1_CellContentClick;
            // 
            // txtFilmAdi
            // 
            txtFilmAdi.Location = new Point(1282, 12);
            txtFilmAdi.Name = "txtFilmAdi";
            txtFilmAdi.Size = new Size(211, 31);
            txtFilmAdi.TabIndex = 6;
            // 
            // txtImdb
            // 
            txtImdb.Location = new Point(1282, 54);
            txtImdb.Name = "txtImdb";
            txtImdb.Size = new Size(211, 31);
            txtImdb.TabIndex = 7;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(1167, 15);
            label1.Name = "label1";
            label1.Size = new Size(78, 25);
            label1.TabIndex = 8;
            label1.Text = "Film adi:";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(1167, 54);
            label2.Name = "label2";
            label2.Size = new Size(58, 25);
            label2.TabIndex = 9;
            label2.Text = "imdb:";
            label2.Click += label2_Click;
            // 
            // cmbKategori
            // 
            cmbKategori.FormattingEnabled = true;
            cmbKategori.Items.AddRange(new object[] { "Animation", "Live Action" });
            cmbKategori.Location = new Point(1282, 91);
            cmbKategori.Name = "cmbKategori";
            cmbKategori.Size = new Size(211, 33);
            cmbKategori.TabIndex = 10;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Location = new Point(1167, 99);
            label3.Name = "label3";
            label3.Size = new Size(81, 25);
            label3.TabIndex = 11;
            label3.Text = "kategori:";
            // 
            // txtId
            // 
            txtId.Location = new Point(1282, 197);
            txtId.Name = "txtId";
            txtId.Size = new Size(150, 31);
            txtId.TabIndex = 12;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Location = new Point(1169, 200);
            label4.Name = "label4";
            label4.Size = new Size(67, 25);
            label4.TabIndex = 13;
            label4.Text = " filmId:";
            // 
            // txtDuration
            // 
            txtDuration.Location = new Point(1282, 147);
            txtDuration.Name = "txtDuration";
            txtDuration.Size = new Size(211, 31);
            txtDuration.TabIndex = 14;
            // 
            // txtAra
            // 
            txtAra.Location = new Point(1343, 466);
            txtAra.Name = "txtAra";
            txtAra.Size = new Size(150, 31);
            txtAra.TabIndex = 15;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Location = new Point(1224, 472);
            label5.Name = "label5";
            label5.Size = new Size(113, 25);
            label5.TabIndex = 16;
            label5.Text = "arama yapin:";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Location = new Point(1169, 147);
            label6.Name = "label6";
            label6.Size = new Size(79, 25);
            label6.TabIndex = 17;
            label6.Text = "sure(dk):";
            // 
            // btnIslem
            // 
            btnIslem.Location = new Point(1461, 519);
            btnIslem.Name = "btnIslem";
            btnIslem.Size = new Size(234, 36);
            btnIslem.TabIndex = 18;
            btnIslem.Text = "diger islemleri gor...";
            btnIslem.UseVisualStyleBackColor = true;
            btnIslem.Click += btnIslem_Click;
            // 
            // btnKisiListele
            // 
            btnKisiListele.Location = new Point(1528, 111);
            btnKisiListele.Name = "btnKisiListele";
            btnKisiListele.Size = new Size(167, 67);
            btnKisiListele.TabIndex = 19;
            btnKisiListele.Text = "Kisileri listele";
            btnKisiListele.UseVisualStyleBackColor = true;
            btnKisiListele.Click += btnKisiListele_Click;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(10F, 25F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1703, 556);
            Controls.Add(btnKisiListele);
            Controls.Add(btnIslem);
            Controls.Add(label6);
            Controls.Add(label5);
            Controls.Add(txtAra);
            Controls.Add(txtDuration);
            Controls.Add(label4);
            Controls.Add(txtId);
            Controls.Add(label3);
            Controls.Add(cmbKategori);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(txtImdb);
            Controls.Add(txtFilmAdi);
            Controls.Add(dataGridView1);
            Controls.Add(btnListele);
            Controls.Add(btnAra);
            Controls.Add(btnGuncelle);
            Controls.Add(btnSil);
            Controls.Add(btnEkle);
            Name = "Form1";
            Text = "Form1";
            ((System.ComponentModel.ISupportInitialize)dataGridView1).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button btnEkle;
        private Button btnSil;
        private Button btnGuncelle;
        private Button btnAra;
        private Button btnListele;
        private DataGridView dataGridView1;
        private TextBox txtFilmAdi;
        private TextBox txtImdb;
        private Label label1;
        private Label label2;
        private ComboBox cmbKategori;
        private Label label3;
        private TextBox txtId;
        private Label label4;
        private TextBox txtDuration;
        private TextBox txtAra;
        private Label label5;
        private Label label6;
        private Button btnIslem;
        private Button btnKisiListele;
    }
}
